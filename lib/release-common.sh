#!/usr/bin/env bash

release_usage_error() {
  echo "$1" >&2
  exit 1
}

release_require_service() {
  case "$1" in
    daedalus|icarus|odin|olympus) ;;
    *) release_usage_error "Unsupported service: $1" ;;
  esac
}

release_normalize_compare_environment() {
  case "$1" in
    staging) echo "staging" ;;
    production|prod) echo "production" ;;
    *) release_usage_error "Unsupported environment: $1" ;;
  esac
}

release_normalize_environment() {
  case "$1" in
    staging) echo "staging" ;;
    production|prod) echo "production" ;;
    both) echo "both" ;;
    *) release_usage_error "Unsupported environment: $1" ;;
  esac
}

release_repo_path() {
  local root=$1
  local service=$2
  echo "$root/repos/$service"
}

release_ops_path() {
  local root=$1
  echo "$root/repos/ops"
}

release_require_initialized_repos() {
  local root=$1
  local service=$2
  local repo_path
  local ops_path
  repo_path=$(release_repo_path "$root" "$service")
  ops_path=$(release_ops_path "$root")

  if [ ! -e "$repo_path/.git" ] || [ ! -e "$ops_path/.git" ]; then
    echo "Required repos are not initialized under repos/" >&2
    exit 1
  fi
}

release_fetch_origin() {
  local root=$1
  local service=$2
  git -C "$(release_repo_path "$root" "$service")" fetch origin >/dev/null
  git -C "$(release_ops_path "$root")" fetch origin >/dev/null
}

release_values_relpath() {
  local service=$1
  local environment=$2
  echo "k8s/$service/values.$environment.yaml"
}

release_values_abspath() {
  local ops_path=$1
  local service=$2
  local environment=$3
  echo "$ops_path/$(release_values_relpath "$service" "$environment")"
}

release_extract_tag_from_stream() {
  grep -E '^[[:space:]]+tag:' | head -1 | awk '{print $2}' | tr -d '\r'
}

release_read_deployed_sha() {
  local root=$1
  local service=$2
  local environment=$3
  local ops_path
  local values_file
  ops_path=$(release_ops_path "$root")
  values_file=$(release_values_relpath "$service" "$environment")

  if ! git -C "$ops_path" show "origin/main:$values_file" >/dev/null 2>&1; then
    echo "Error: $values_file not found on ops origin/main" >&2
    exit 1
  fi

  local deployed_sha
  deployed_sha=$(git -C "$ops_path" show "origin/main:$values_file" | release_extract_tag_from_stream)

  if [ -z "$deployed_sha" ]; then
    echo "Error: could not read deployed SHA from ops origin/main:$values_file" >&2
    exit 1
  fi

  echo "$deployed_sha"
}

release_require_commit() {
  local root=$1
  local service=$2
  local label=$3
  local sha=$4
  local repo_path
  repo_path=$(release_repo_path "$root" "$service")

  if ! git -C "$repo_path" cat-file -e "${sha}^{commit}" 2>/dev/null; then
    echo "Error: $label SHA '$sha' not found in $service" >&2
    exit 1
  fi
}

release_resolve_target_sha() {
  local root=$1
  local service=$2
  local target_input=${3:-}
  local repo_path
  repo_path=$(release_repo_path "$root" "$service")

  if [ -n "$target_input" ]; then
    release_require_commit "$root" "$service" "target" "$target_input"
    git -C "$repo_path" rev-parse "$target_input"
  else
    git -C "$repo_path" rev-parse origin/main
  fi
}

release_short_sha() {
  local root=$1
  local service=$2
  local sha=$3
  git -C "$(release_repo_path "$root" "$service")" rev-parse --short "$sha"
}

release_commit_subject() {
  local root=$1
  local service=$2
  local sha=$3
  git -C "$(release_repo_path "$root" "$service")" log -1 --format="%s" "$sha"
}

release_commit_list() {
  local root=$1
  local service=$2
  local old_sha=$3
  local new_sha=$4
  local format=$5
  git -C "$(release_repo_path "$root" "$service")" log --format="$format" "${old_sha}..${new_sha}"
}

release_changed_files() {
  local service=$1
  local environment=$2

  case "$environment" in
    staging)
      printf '%s\n' "$(release_values_relpath "$service" staging)"
      ;;
    production)
      printf '%s\n' "$(release_values_relpath "$service" production)"
      ;;
    both)
      printf '%s\n' "$(release_values_relpath "$service" staging)" "$(release_values_relpath "$service" production)"
      ;;
  esac
}

release_short_description() {
  local subject=$1
  local short_description
  short_description=$(printf '%s' "$subject" | sed -E 's/^[^:]+:[[:space:]]*//; s/[[:space:]]+\(#([0-9]+)\)$//')
  if [ -z "$short_description" ]; then
    short_description=$subject
  fi
  echo "$short_description"
}

release_commit_message() {
  local service=$1
  local environment=$2
  local subject=$3
  echo "release $service on $environment, $(release_short_description "$subject")"
}

release_pr_title() {
  local root=$1
  local service=$2
  local new_sha=$3
  release_commit_subject "$root" "$service" "$new_sha"
}

release_write_pr_body() {
  local root=$1
  local service=$2
  local new_sha=$3
  local environment=$4
  local target_file=$5
  local staging_old_sha=$6
  local production_old_sha=$7

  local new_short
  local staging_old_short
  local production_old_short
  local staging_commits
  local production_commits
  local staging_file
  local production_file

  new_short=$(release_short_sha "$root" "$service" "$new_sha")
  staging_file=$(release_values_relpath "$service" staging)
  production_file=$(release_values_relpath "$service" production)

  case "$environment" in
    staging)
      release_require_commit "$root" "$service" "old" "$staging_old_sha"
      staging_old_short=$(release_short_sha "$root" "$service" "$staging_old_sha")
      staging_commits=$(release_commit_list "$root" "$service" "$staging_old_sha" "$new_sha" '- `%h` %s')
      cat >"$target_file" <<EOF
## Release: $service (staging only)

| | SHA |
|---|---|
| Old (staging) | \`$staging_old_sha\` |
| New (staging) | \`$new_sha\` |

**Staging image tag:** \`$staging_old_short\` -> \`$new_short\`

## Commits ($staging_old_short...$new_short)

$staging_commits

## Changed Files

- \`$staging_file\`
EOF
      ;;
    production)
      release_require_commit "$root" "$service" "old" "$production_old_sha"
      production_old_short=$(release_short_sha "$root" "$service" "$production_old_sha")
      production_commits=$(release_commit_list "$root" "$service" "$production_old_sha" "$new_sha" '- `%h` %s')
      cat >"$target_file" <<EOF
## Release: $service (production only)

| | SHA |
|---|---|
| Old (production) | \`$production_old_sha\` |
| New (production) | \`$new_sha\` |

**Production image tag:** \`$production_old_short\` -> \`$new_short\`

## Commits ($production_old_short...$new_short)

$production_commits

## Changed Files

- \`$production_file\`
EOF
      ;;
    both)
      release_require_commit "$root" "$service" "staging old" "$staging_old_sha"
      release_require_commit "$root" "$service" "production old" "$production_old_sha"
      staging_old_short=$(release_short_sha "$root" "$service" "$staging_old_sha")
      production_old_short=$(release_short_sha "$root" "$service" "$production_old_sha")
      staging_commits=$(release_commit_list "$root" "$service" "$staging_old_sha" "$new_sha" '- `%h` %s')
      if [ "$staging_old_sha" = "$production_old_sha" ]; then
        cat >"$target_file" <<EOF
## Release: $service

| | SHA |
|---|---|
| Old (staging) | \`$staging_old_sha\` |
| New (staging) | \`$new_sha\` |
| Old (production) | \`$production_old_sha\` |
| New (production) | \`$new_sha\` |

**Staging image tag:** \`$staging_old_short\` -> \`$new_short\`
**Production image tag:** \`$production_old_short\` -> \`$new_short\`

## Commits ($staging_old_short...$new_short)

$staging_commits

## Changed Files

- \`$staging_file\`
- \`$production_file\`
EOF
      else
        production_commits=$(release_commit_list "$root" "$service" "$production_old_sha" "$new_sha" '- `%h` %s')
        cat >"$target_file" <<EOF
## Release: $service

| | SHA |
|---|---|
| Old (staging) | \`$staging_old_sha\` |
| New (staging) | \`$new_sha\` |
| Old (production) | \`$production_old_sha\` |
| New (production) | \`$new_sha\` |

**Staging image tag:** \`$staging_old_short\` -> \`$new_short\`
**Production image tag:** \`$production_old_short\` -> \`$new_short\`

## Staging Commits ($staging_old_short...$new_short)

$staging_commits

## Production Commits ($production_old_short...$new_short)

$production_commits

## Changed Files

- \`$staging_file\`
- \`$production_file\`
EOF
      fi
      ;;
  esac
}

release_print_pr_content() {
  local root=$1
  local service=$2
  local new_sha=$3
  local environment=$4
  local body_file=$5
  local staging_old_sha=$6
  local production_old_sha=$7

  echo "=== PR TITLE ==="
  release_pr_title "$root" "$service" "$new_sha"
  echo ""
  echo "=== PR BODY ==="
  release_write_pr_body "$root" "$service" "$new_sha" "$environment" "$body_file" "$staging_old_sha" "$production_old_sha"
  cat "$body_file"
}
