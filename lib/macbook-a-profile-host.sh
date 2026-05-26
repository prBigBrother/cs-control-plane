#!/usr/bin/env bash
#
# MacBook A Chrome Profile Host
# -----------------------------
# Canonical machine: MacBook A
# LAN IP: 192.168.100.23
# Chrome executable:
#   /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
# Canonical profile:
#   /Users/prbigbrother/Library/Application Support/Google/Chrome/Profile 16
#
# Purpose:
# - Check that Remote Login / SSH is enabled.
# - Verify the canonical Chrome profile exists.
# - Warn if Chrome appears to be using Profile 16.
# - Optionally quit Chrome only after explicit confirmation.
# - Print the exact rsync source MacBook B should use.
# - Create/remove a lock marker near the profile for sync coordination.
#
# Setup:
#   chmod +x macbook-a-profile-host.sh
#   ./macbook-a-profile-host.sh --status
#
# Important:
# - Do not run Chrome with Profile 16 on MacBook A while MacBook B is using it.
# - This script never deletes the canonical Chrome profile.
# - The lock marker is advisory. Chrome does not honor it automatically.

set -euo pipefail

LAN_IP="${LAN_IP:-192.168.100.23}"
SSH_USERNAME="${SSH_USERNAME:-$(id -un)}"
CHROME_EXECUTABLE="${CHROME_EXECUTABLE:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
PROFILE_PATH="${PROFILE_PATH:-/Users/prbigbrother/Library/Application Support/Google/Chrome/Profile 16}"
LOCK_FILE="${LOCK_FILE:-${PROFILE_PATH}.remote-sync.lock}"

usage() {
  cat <<EOF
Usage: $0 [--status|--lock|--unlock|--check-profile|--check-chrome]

Modes:
  default, --status   Print host readiness and sync details.
  --lock              Create advisory remote sync lock marker.
  --unlock            Remove advisory remote sync lock marker.
  --check-profile     Verify the canonical profile path exists.
  --check-chrome      Check whether Chrome appears to be using Profile 16.

Environment overrides:
  LAN_IP              Default: $LAN_IP
  SSH_USERNAME        Default: $SSH_USERNAME
  CHROME_EXECUTABLE   Default: $CHROME_EXECUTABLE
  PROFILE_PATH        Default: $PROFILE_PATH
  LOCK_FILE           Default: $LOCK_FILE

MacBook B rsync source:
  ${SSH_USERNAME}@${LAN_IP}:'${PROFILE_PATH}/'
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

check_profile() {
  status "Checking canonical Chrome profile path"
  if [[ ! -d "$PROFILE_PATH" ]]; then
    fail "Profile path does not exist: $PROFILE_PATH"
  fi
  status "Profile exists: $PROFILE_PATH"
}

check_chrome_executable() {
  status "Checking Chrome executable path"
  if [[ -x "$CHROME_EXECUTABLE" ]]; then
    status "Chrome executable exists: $CHROME_EXECUTABLE"
  else
    warn "Chrome executable was not found or is not executable: $CHROME_EXECUTABLE"
  fi
}

ssh_status() {
  status "Checking Remote Login / SSH"

  if ! command -v systemsetup >/dev/null 2>&1; then
    warn "systemsetup is not available; cannot automatically check Remote Login."
    warn "On MacBook A, enable SSH with: System Settings > General > Sharing > Remote Login"
    return 0
  fi

  local remote_login
  remote_login="$(systemsetup -getremotelogin 2>/dev/null || true)"

  if printf '%s\n' "$remote_login" | grep -qi 'Remote Login: On'; then
    status "Remote Login is enabled"
    return 0
  fi

  warn "Remote Login does not appear to be enabled."
  warn "Enable it with: System Settings > General > Sharing > Remote Login"
  warn "Or from Terminal: sudo systemsetup -setremotelogin on"
}

chrome_processes() {
  ps axww -o pid= -o command= | grep -E '[G]oogle Chrome|[C]hrome' || true
}

chrome_profile_matches() {
  local processes
  processes="$(chrome_processes)"

  {
    printf '%s\n' "$processes" | grep -F -- "$PROFILE_PATH" || true
    printf '%s\n' "$processes" | grep -F -- '--profile-directory=Profile 16' || true
  } | awk 'NF && !seen[$0]++'
}

lsof_profile_matches() {
  if ! command -v lsof >/dev/null 2>&1; then
    return 0
  fi

  lsof +D "$PROFILE_PATH" 2>/dev/null | awk 'NR > 1 { print }' || true
}

check_chrome() {
  status "Checking whether Chrome appears to be using Profile 16"

  local matches lsof_matches
  matches="$(chrome_profile_matches)"
  lsof_matches=""

  if [[ -d "$PROFILE_PATH" ]]; then
    lsof_matches="$(lsof_profile_matches)"
  fi

  if [[ -n "$matches" || -n "$lsof_matches" ]]; then
    warn "Chrome appears to be using Profile 16. MacBook B must not sync while this is true."
    if [[ -n "$matches" ]]; then
      printf '%s\n' "$matches"
    fi
    if [[ -n "$lsof_matches" ]]; then
      printf '%s\n' "Open files under profile:"
      printf '%s\n' "$lsof_matches" | sed -n '1,20p'
      local lsof_count
      lsof_count="$(printf '%s\n' "$lsof_matches" | awk 'NF { count++ } END { print count + 0 }')"
      if [[ "$lsof_count" -gt 20 ]]; then
        printf '%s\n' "... ${lsof_count} total open file rows"
      fi
    fi
    offer_stop_chrome
    return 1
  fi

  status "No Chrome process was detected using Profile 16"
}

offer_stop_chrome() {
  if [[ ! -t 0 ]]; then
    warn "Not prompting to quit Chrome because stdin is not interactive."
    return 0
  fi

  printf '%s' "Quit all Google Chrome windows on this Mac now? [y/N] "
  local reply
  read -r reply
  case "$reply" in
    y|Y|yes|YES)
      status "Asking Google Chrome to quit"
      osascript -e 'tell application "Google Chrome" to quit' >/dev/null 2>&1 || warn "Could not ask Chrome to quit via osascript."
      sleep 3
      ;;
    *)
      status "Leaving Chrome running"
      ;;
  esac
}

print_sync_details() {
  status "MacBook B connection details"
  printf '%s\n' "LAN IP: $LAN_IP"
  printf '%s\n' "SSH username: $SSH_USERNAME"
  printf '%s\n' "Remote host: ${SSH_USERNAME}@${LAN_IP}"
  printf '%s\n' "Chrome executable: $CHROME_EXECUTABLE"
  printf '%s\n' "Remote profile path: $PROFILE_PATH"
  printf '%s\n' "Rsync source argument:"
  printf '%s\n' "  ${SSH_USERNAME}@${LAN_IP}:'${PROFILE_PATH}/'"
  printf '%s\n' "Lock marker:"
  printf '%s\n' "  $LOCK_FILE"
}

show_lock() {
  if [[ -e "$LOCK_FILE" ]]; then
    warn "Lock marker exists: $LOCK_FILE"
    sed -n '1,20p' "$LOCK_FILE" || true
  else
    status "No lock marker exists: $LOCK_FILE"
  fi
}

create_lock() {
  check_profile
  if [[ -e "$LOCK_FILE" ]]; then
    fail "Lock marker already exists: $LOCK_FILE"
  fi

  status "Creating advisory lock marker"
  {
    printf '%s\n' "created_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf '%s\n' "host=$(hostname)"
    printf '%s\n' "user=$(id -un)"
    printf '%s\n' "pid=$$"
    printf '%s\n' "purpose=remote Chrome profile sync"
  } > "$LOCK_FILE"

  status "Created lock marker: $LOCK_FILE"
}

remove_lock() {
  if [[ ! -e "$LOCK_FILE" ]]; then
    status "No lock marker to remove: $LOCK_FILE"
    return 0
  fi

  status "Current lock marker contents"
  sed -n '1,20p' "$LOCK_FILE" || true

  if [[ -t 0 ]]; then
    printf '%s' "Remove this advisory lock marker? [y/N] "
    local reply
    read -r reply
    case "$reply" in
      y|Y|yes|YES) ;;
      *) status "Leaving lock marker in place"; return 0 ;;
    esac
  fi

  rm -f "$LOCK_FILE"
  status "Removed lock marker: $LOCK_FILE"
}

run_status() {
  print_sync_details
  check_profile
  check_chrome_executable
  ssh_status
  show_lock

  if ! check_chrome; then
    return 0
  fi
}

mode="${1:---status}"

case "$mode" in
  --status)
    run_status
    ;;
  --lock)
    create_lock
    ;;
  --unlock)
    remove_lock
    ;;
  --check-profile)
    check_profile
    ;;
  --check-chrome)
    check_chrome
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
