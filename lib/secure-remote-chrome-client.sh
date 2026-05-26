#!/usr/bin/env bash
#
# Secure Remote Chrome Client for MacBook B
# -----------------------------------------
# Canonical host: MacBook A
# Remote host: prbigbrother@192.168.100.23
# Remote canonical profile:
#   /Users/prbigbrother/Library/Application Support/Google/Chrome/Profile 16
#
# Purpose:
# - Keep the real Chrome profile on MacBook A.
# - Copy Profile 16 into an encrypted APFS sparsebundle on MacBook B.
# - Run local Chrome using the encrypted mounted copy.
# - After Chrome exits, sync changes back to MacBook A.
# - Leave no plaintext profile on MacBook B outside the mounted encrypted volume.
#
# Setup:
#   chmod +x secure-remote-chrome-client.sh
#   ./secure-remote-chrome-client.sh --init
#   ./secure-remote-chrome-client.sh
#
# Important:
# - Do not run Chrome with Profile 16 on MacBook A while this script is active.
# - This script never deletes the canonical profile on MacBook A.
# - This script never deletes the local encrypted sparsebundle.
# - The sparsebundle passphrase is entered into hdiutil/macOS prompts; it is not stored here.
# - This does not use Chrome Remote Desktop, remote profile mounts, or browser automation.

set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:-prbigbrother@192.168.100.23}"
REMOTE_PROFILE_PATH="${REMOTE_PROFILE_PATH:-/Users/prbigbrother/Library/Application Support/Google/Chrome/Profile 16}"
LOCAL_SPARSEBUNDLE="${LOCAL_SPARSEBUNDLE:-$HOME/SecureChromeProfile.sparsebundle}"
VOLUME_NAME="${VOLUME_NAME:-SecureChromeProfile}"
LOCAL_PROFILE_PATH="${LOCAL_PROFILE_PATH:-/Volumes/${VOLUME_NAME}/Profile 16}"
CHROME_APP="${CHROME_APP:-Google Chrome}"
SPARSEBUNDLE_SIZE="${SPARSEBUNDLE_SIZE:-20g}"

MOUNT_POINT="/Volumes/$VOLUME_NAME"
LOCAL_LOCK_FILE="${LOCAL_LOCK_FILE:-$HOME/.secure-remote-chrome-client.lock}"
REMOTE_LOCK_FILE="${REMOTE_LOCK_FILE:-${REMOTE_PROFILE_PATH}.remote-sync.lock}"
LOCK_TOKEN="${LOCK_TOKEN:-$(hostname)-$$-$(date +%s)}"

REMOTE_LOCK_HELD=0
LOCAL_LOCK_HELD=0
MOUNTED_BY_SCRIPT=0
RSYNC_EXCLUDE_ARGS=(
  --exclude 'SingletonLock'
  --exclude 'SingletonSocket'
  --exclude 'SingletonCookie'
  --exclude 'Crashpad'
  --exclude 'BrowserMetrics'
  --exclude '*.tmp'
)

usage() {
  cat <<EOF
Usage: $0 [mode]

Modes:
  default            Full workflow: lock, mount, sync down, run Chrome, sync up, unmount.
  --init             Create the encrypted APFS sparsebundle if missing.
  --sync-down-only   Mount if needed and sync MacBook A profile into the encrypted volume.
  --sync-up-only     Mount if needed and sync encrypted profile changes back to MacBook A.
  --mount            Mount the encrypted sparsebundle.
  --unmount          Detach the encrypted sparsebundle.
  --status           Print local/remote status.

Configuration environment variables:
  REMOTE_HOST            Default: $REMOTE_HOST
  REMOTE_PROFILE_PATH    Default: $REMOTE_PROFILE_PATH
  LOCAL_SPARSEBUNDLE     Default: $LOCAL_SPARSEBUNDLE
  VOLUME_NAME            Default: $VOLUME_NAME
  LOCAL_PROFILE_PATH     Default: $LOCAL_PROFILE_PATH
  CHROME_APP             Default: $CHROME_APP
  SPARSEBUNDLE_SIZE      Default: $SPARSEBUNDLE_SIZE

Examples:
  chmod +x secure-remote-chrome-client.sh
  ./secure-remote-chrome-client.sh --init
  ./secure-remote-chrome-client.sh
EOF
}

status() {
  printf '%s\n' "==> $*"
}

warn() {
  printf '%s\n' "WARNING: $*" >&2
}

fail() {
  printf '%s\n' "ERROR: $*" >&2
  exit 1
}

cleanup() {
  local exit_code=$?
  trap - EXIT INT TERM

  if [[ "$REMOTE_LOCK_HELD" -eq 1 ]]; then
    release_remote_lock || warn "Could not release remote lock: $REMOTE_LOCK_FILE"
  fi

  if [[ "$MOUNTED_BY_SCRIPT" -eq 1 ]]; then
    if chrome_using_local_profile >/dev/null 2>&1; then
      warn "Chrome still appears to be using $LOCAL_PROFILE_PATH; leaving volume mounted."
    else
      detach_volume || warn "Could not detach volume: $MOUNT_POINT"
    fi
  fi

  if [[ "$LOCAL_LOCK_HELD" -eq 1 ]]; then
    rm -f "$LOCAL_LOCK_FILE"
  fi

  exit "$exit_code"
}

trap cleanup EXIT INT TERM

require_tool() {
  local tool="$1"
  command -v "$tool" >/dev/null 2>&1 || fail "Required tool not found: $tool"
}

verify_tools() {
  status "Checking required tools"
  require_tool ssh
  require_tool rsync
  require_tool hdiutil
  require_tool open
}

test_ssh() {
  status "Testing SSH connection to $REMOTE_HOST"
  ssh -o ConnectTimeout=10 "$REMOTE_HOST" "true" || fail "SSH connection failed. On MacBook A, enable System Settings > General > Sharing > Remote Login."
}

remote_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

remote_profile_source() {
  printf "%s:%s" "$REMOTE_HOST" "$(remote_quote "${REMOTE_PROFILE_PATH}/")"
}

remote_profile_destination() {
  printf "%s:%s" "$REMOTE_HOST" "$(remote_quote "${REMOTE_PROFILE_PATH}/")"
}

remote_chrome_check_script() {
  cat <<'REMOTE_SCRIPT'
set -euo pipefail
profile_path="$1"
processes="$(ps axww -o pid= -o command= | grep -E '[G]oogle Chrome|[C]hrome' || true)"
matches="$(
  {
    printf '%s\n' "$processes" | grep -F -- "$profile_path" || true
    printf '%s\n' "$processes" | grep -F -- '--profile-directory=Profile 16' || true
  } | awk 'NF && !seen[$0]++'
)"
lsof_matches=""
if command -v lsof >/dev/null 2>&1 && [ -d "$profile_path" ]; then
  lsof_matches="$(lsof +D "$profile_path" 2>/dev/null | awk 'NR > 1 { print }' || true)"
fi
if [ -n "$matches" ] || [ -n "$lsof_matches" ]; then
  printf '%s\n' "$matches"
  if [ -n "$lsof_matches" ]; then
    printf '%s\n' "Open files under profile:"
    printf '%s\n' "$lsof_matches" | sed -n '1,20p'
  fi
  exit 1
fi
REMOTE_SCRIPT
}

refuse_if_remote_chrome_using_profile() {
  status "Checking MacBook A for Chrome using Profile 16"
  if ! remote_chrome_check_output="$(remote_chrome_check_script | ssh "$REMOTE_HOST" "bash -s -- $(remote_quote "$REMOTE_PROFILE_PATH")" 2>&1)"; then
    printf '%s\n' "$remote_chrome_check_output" >&2
    fail "MacBook A appears to be using Profile 16. Quit Chrome on MacBook A before syncing."
  fi
  status "MacBook A does not appear to be using Profile 16"
}

acquire_local_lock() {
  status "Acquiring local lock"

  if [[ -e "$LOCAL_LOCK_FILE" ]]; then
    local existing_pid
    existing_pid="$(awk -F= '$1 == "pid" { print $2 }' "$LOCAL_LOCK_FILE" 2>/dev/null || true)"
    if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
      fail "Another local run appears active with PID $existing_pid. Lock: $LOCAL_LOCK_FILE"
    fi
    warn "Removing stale local lock: $LOCAL_LOCK_FILE"
    rm -f "$LOCAL_LOCK_FILE"
  fi

  set -C
  {
    printf '%s\n' "pid=$$"
    printf '%s\n' "host=$(hostname)"
    printf '%s\n' "created_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf '%s\n' "remote_host=$REMOTE_HOST"
    printf '%s\n' "token=$LOCK_TOKEN"
  } > "$LOCAL_LOCK_FILE"
  set +C

  LOCAL_LOCK_HELD=1
}

remote_lock_create_script() {
  cat <<'REMOTE_SCRIPT'
set -euo pipefail
lock_file="$1"
profile_path="$2"
token="$3"

if [ ! -d "$profile_path" ]; then
  printf '%s\n' "Remote profile path does not exist: $profile_path" >&2
  exit 3
fi

if [ -e "$lock_file" ]; then
  printf '%s\n' "Remote lock already exists: $lock_file" >&2
  sed -n '1,20p' "$lock_file" >&2 || true
  exit 2
fi

set -C
{
  printf '%s\n' "created_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf '%s\n' "host=$(hostname)"
  printf '%s\n' "user=$(id -un)"
  printf '%s\n' "pid=$$"
  printf '%s\n' "token=$token"
  printf '%s\n' "purpose=secure remote Chrome profile sync"
} > "$lock_file"
REMOTE_SCRIPT
}

acquire_remote_lock() {
  status "Acquiring remote advisory lock on MacBook A"
  remote_lock_create_script | ssh "$REMOTE_HOST" "bash -s -- $(remote_quote "$REMOTE_LOCK_FILE") $(remote_quote "$REMOTE_PROFILE_PATH") $(remote_quote "$LOCK_TOKEN")"
  REMOTE_LOCK_HELD=1
}

remote_lock_release_script() {
  cat <<'REMOTE_SCRIPT'
set -euo pipefail
lock_file="$1"
token="$2"

if [ ! -e "$lock_file" ]; then
  exit 0
fi

existing_token="$(awk -F= '$1 == "token" { print $2 }' "$lock_file" 2>/dev/null || true)"
if [ "$existing_token" != "$token" ]; then
  printf '%s\n' "Remote lock token does not match; refusing to remove: $lock_file" >&2
  exit 1
fi

rm -f "$lock_file"
REMOTE_SCRIPT
}

release_remote_lock() {
  status "Releasing remote advisory lock"
  remote_lock_release_script | ssh "$REMOTE_HOST" "bash -s -- $(remote_quote "$REMOTE_LOCK_FILE") $(remote_quote "$LOCK_TOKEN")"
  REMOTE_LOCK_HELD=0
}

is_mounted() {
  mount | grep -F " on $MOUNT_POINT " >/dev/null 2>&1
}

create_sparsebundle() {
  if [[ -e "$LOCAL_SPARSEBUNDLE" ]]; then
    status "Encrypted sparsebundle already exists: $LOCAL_SPARSEBUNDLE"
    return 0
  fi

  status "Creating encrypted APFS sparsebundle: $LOCAL_SPARSEBUNDLE"
  status "hdiutil will prompt for a new encryption passphrase; the script will not store it."
  hdiutil create \
    -type SPARSEBUNDLE \
    -fs APFS \
    -encryption AES-256 \
    -size "$SPARSEBUNDLE_SIZE" \
    -volname "$VOLUME_NAME" \
    "$LOCAL_SPARSEBUNDLE"
}

mount_sparsebundle() {
  create_sparsebundle

  if is_mounted; then
    status "Encrypted volume already mounted: $MOUNT_POINT"
    return 0
  fi

  status "Mounting encrypted sparsebundle"
  hdiutil attach "$LOCAL_SPARSEBUNDLE" -mountpoint "$MOUNT_POINT"
  MOUNTED_BY_SCRIPT=1
}

ensure_volume_ready() {
  mount_sparsebundle

  if [[ ! -d "$MOUNT_POINT" ]]; then
    fail "Mounted volume path does not exist: $MOUNT_POINT"
  fi
  if [[ ! -w "$MOUNT_POINT" ]]; then
    fail "Mounted volume is not writable: $MOUNT_POINT"
  fi

  mkdir -p "$LOCAL_PROFILE_PATH"
}

sync_down() {
  ensure_volume_ready
  status "Syncing Profile 16 from MacBook A into encrypted volume"
  rsync -av --delete "${RSYNC_EXCLUDE_ARGS[@]}" "$(remote_profile_source)" "$LOCAL_PROFILE_PATH/"
}

sync_up() {
  ensure_volume_ready
  if [[ ! -d "$LOCAL_PROFILE_PATH" ]]; then
    fail "Local encrypted profile path does not exist: $LOCAL_PROFILE_PATH"
  fi

  status "Syncing encrypted local Profile 16 changes back to MacBook A"
  rsync -av --delete "${RSYNC_EXCLUDE_ARGS[@]}" "$LOCAL_PROFILE_PATH/" "$(remote_profile_destination)"
}

chrome_using_local_profile() {
  ps axww -o pid= -o command= | grep -F -- "$LOCAL_PROFILE_PATH" | grep -E '[G]oogle Chrome|[C]hrome' || true
}

launch_chrome_and_wait() {
  status "Launching local Chrome with encrypted profile copy"
  open -a "$CHROME_APP" --args --user-data-dir="$LOCAL_PROFILE_PATH"

  status "Waiting for Chrome process using this profile to appear"
  local waited
  waited=0
  while ! chrome_using_local_profile >/dev/null 2>&1; do
    sleep 1
    waited=$((waited + 1))
    if [[ "$waited" -ge 30 ]]; then
      fail "Chrome did not appear to start with --user-data-dir=$LOCAL_PROFILE_PATH. Close any existing Chrome instances and try again."
    fi
  done

  status "Chrome is running with encrypted profile copy. Waiting for it to exit."
  while chrome_using_local_profile >/dev/null 2>&1; do
    sleep 5
  done
  status "Chrome exited"
}

detach_volume() {
  if ! is_mounted; then
    status "Encrypted volume is not mounted: $MOUNT_POINT"
    MOUNTED_BY_SCRIPT=0
    return 0
  fi

  status "Detaching encrypted volume: $MOUNT_POINT"
  hdiutil detach "$MOUNT_POINT"
  MOUNTED_BY_SCRIPT=0
}

print_status() {
  printf '%s\n' "Remote host: $REMOTE_HOST"
  printf '%s\n' "Remote profile: $REMOTE_PROFILE_PATH"
  printf '%s\n' "Remote lock: $REMOTE_LOCK_FILE"
  printf '%s\n' "Local sparsebundle: $LOCAL_SPARSEBUNDLE"
  printf '%s\n' "Volume name: $VOLUME_NAME"
  printf '%s\n' "Mount point: $MOUNT_POINT"
  printf '%s\n' "Local encrypted profile: $LOCAL_PROFILE_PATH"
  printf '%s\n' "Chrome app: $CHROME_APP"

  if [[ -e "$LOCAL_SPARSEBUNDLE" ]]; then
    status "Sparsebundle exists"
  else
    warn "Sparsebundle does not exist yet"
  fi

  if is_mounted; then
    status "Encrypted volume is mounted"
  else
    warn "Encrypted volume is not mounted"
  fi

  if [[ -e "$LOCAL_LOCK_FILE" ]]; then
    warn "Local lock exists: $LOCAL_LOCK_FILE"
    sed -n '1,20p' "$LOCAL_LOCK_FILE" || true
  else
    status "No local lock exists"
  fi
}

full_workflow() {
  verify_tools
  acquire_local_lock
  test_ssh
  refuse_if_remote_chrome_using_profile
  acquire_remote_lock
  ensure_volume_ready
  sync_down
  launch_chrome_and_wait
  refuse_if_remote_chrome_using_profile
  sync_up
  detach_volume
  release_remote_lock
  rm -f "$LOCAL_LOCK_FILE"
  LOCAL_LOCK_HELD=0
}

mode="${1:-default}"

case "$mode" in
  default)
    full_workflow
    ;;
  --init)
    verify_tools
    acquire_local_lock
    create_sparsebundle
    rm -f "$LOCAL_LOCK_FILE"
    LOCAL_LOCK_HELD=0
    ;;
  --sync-down-only)
    verify_tools
    acquire_local_lock
    test_ssh
    refuse_if_remote_chrome_using_profile
    acquire_remote_lock
    sync_down
    release_remote_lock
    rm -f "$LOCAL_LOCK_FILE"
    LOCAL_LOCK_HELD=0
    ;;
  --sync-up-only)
    verify_tools
    acquire_local_lock
    test_ssh
    refuse_if_remote_chrome_using_profile
    acquire_remote_lock
    sync_up
    release_remote_lock
    rm -f "$LOCAL_LOCK_FILE"
    LOCAL_LOCK_HELD=0
    ;;
  --mount)
    verify_tools
    mount_sparsebundle
    MOUNTED_BY_SCRIPT=0
    ;;
  --unmount)
    verify_tools
    detach_volume
    ;;
  --status)
    verify_tools
    print_status
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
