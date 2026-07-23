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
  git -C "$(release_repo_path "$root" "$service")" fetch --quiet origin
  git -C "$(release_ops_path "$root")" fetch --quiet origin
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

release_env_names_for_ref() {
  local root=$1
  local service=$2
  local ref=$3
  local repo_path
  repo_path=$(release_repo_path "$root" "$service")

  git -C "$repo_path" grep -h -I -E 'process[.]env([.]|[[:space:]]*[[])|import[.]meta[.]env([.]|[[:space:]]*[[])|window[.]__ENV__([.]|[[:space:]]*[[])|env[(][[:space:]]*["'\''`]' "$ref" -- \
    '*.js' '*.jsx' '*.ts' '*.tsx' '*.cjs' '*.mjs' 2>/dev/null \
    | perl -ne '
      while (/(?:process\.env|import\.meta\.env|window\.__ENV__)\.([A-Z][A-Z0-9_]*)/g) { print "$1\n" }
      while (/(?:process\.env|import\.meta\.env|window\.__ENV__)\[\s*["'\''`]([A-Z][A-Z0-9_]*)["'\''`]\s*\]/g) { print "$1\n" }
      while (/\benv\(\s*["'\''`]([A-Z][A-Z0-9_]*)["'\''`]/g) { print "$1\n" }
    ' \
    | grep -Ev '^(NODE_ENV|npm_package_version)$' \
    | sort -u || true
}

release_new_env_names() {
  local root=$1
  local service=$2
  local old_sha=$3
  local new_sha=$4
  local old_file
  local new_file
  old_file=$(mktemp)
  new_file=$(mktemp)

  release_env_names_for_ref "$root" "$service" "$old_sha" >"$old_file"
  release_env_names_for_ref "$root" "$service" "$new_sha" >"$new_file"
  comm -13 "$old_file" "$new_file"

  rm -f "$old_file" "$new_file"
}

release_ops_configmap_keys() {
  local root=$1
  local service=$2
  local environment=$3
  local ops_path
  local values_file
  ops_path=$(release_ops_path "$root")
  values_file=$(release_values_relpath "$service" "$environment")

  git -C "$ops_path" show "origin/main:$values_file" 2>/dev/null | awk '
    /^configMap:[[:space:]]*$/ { in_config = 1; next }
    in_config && /^[^[:space:]]/ { in_config = 0 }
    in_config && /^[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:/ {
      key = $0
      sub(/^[[:space:]]+/, "", key)
      sub(/[[:space:]]*:.*/, "", key)
      print key
    }
  ' | sort -u
}

release_vault_secret_path() {
  local root=$1
  local service=$2
  local environment=$3
  local ops_path
  local values_file
  local secret_path
  ops_path=$(release_ops_path "$root")
  values_file=$(release_values_relpath "$service" "$environment")

  if [ "$service" = "daedalus" ]; then
    secret_path=$(git -C "$ops_path" show "origin/main:$values_file" 2>/dev/null | awk '
      /^secretPath:[[:space:]]*/ {
        value = $0
        sub(/^secretPath:[[:space:]]*/, "", value)
        gsub(/["'\''\r]/, "", value)
        print value
        exit
      }
    ')
    if [ -n "$secret_path" ]; then
      echo "app/$secret_path/daedalus"
      return 0
    fi
  fi

  git -C "$ops_path" show "origin/main:$values_file" 2>/dev/null | awk '
    /^vault:[[:space:]]*$/ { in_vault = 1; next }
    in_vault && /^[^[:space:]]/ { in_vault = 0 }
    in_vault && /^[[:space:]]+secretspath:[[:space:]]*/ {
      value = $0
      sub(/^[[:space:]]+secretspath:[[:space:]]*/, "", value)
      gsub(/["'\''\r]/, "", value)
      print value
      exit
    }
  '
}

release_append_env_report_for_environment() {
  local root=$1
  local service=$2
  local old_sha=$3
  local new_sha=$4
  local environment=$5
  local target_file=$6
  local env_file
  local configmap_file
  local vault_path
  local env_name
  local has_missing=0

  env_file=$(mktemp)
  configmap_file=$(mktemp)
  release_new_env_names "$root" "$service" "$old_sha" "$new_sha" >"$env_file"
  release_ops_configmap_keys "$root" "$service" "$environment" >"$configmap_file"
  vault_path=$(release_vault_secret_path "$root" "$service" "$environment")

  {
    echo ""
    echo "### $environment"
    if [ ! -s "$env_file" ]; then
      echo ""
      echo "No new environment parameters detected for $environment."
    else
      echo ""
      echo "| Name | Current ops coverage | Release action |"
      echo "|---|---|---|"
      while IFS= read -r env_name; do
        [ -n "$env_name" ] || continue
        if grep -qxF "$env_name" "$configmap_file"; then
          printf '| `%s` | `configMap` in `%s` | Confirm the existing configured value is valid for this release. |\n' "$env_name" "$(release_values_relpath "$service" "$environment")"
        else
          has_missing=1
          if [ -n "$vault_path" ]; then
            printf '| `%s` | Not present in ops `configMap`; Vault is extracted from `%s` | Add the non-secret value to `%s`, or confirm/add the secret in Vault before merge. |\n' "$env_name" "$vault_path" "$(release_values_relpath "$service" "$environment")"
          else
            printf '| `%s` | Not present in ops `configMap`; no Vault path detected | Add the value to `%s` before merge. |\n' "$env_name" "$(release_values_relpath "$service" "$environment")"
          fi
        fi
      done <"$env_file"
      if [ "$has_missing" -ne 0 ]; then
        echo ""
        echo "**Release question:** Update the ops values YAML for non-secret parameters and confirm any Vault additions before merging."
      fi
    fi
  } >>"$target_file"

  rm -f "$env_file" "$configmap_file"
}

release_append_env_report() {
  local root=$1
  local service=$2
  local new_sha=$3
  local environment=$4
  local target_file=$5
  local staging_old_sha=$6
  local production_old_sha=$7

  {
    echo ""
    echo "## Environment Parameters"
    echo ""
    echo "This compares newly referenced environment parameters in the app code against the currently deployed SHA. Vault contents cannot be inspected here, so secret-backed additions require explicit confirmation."
  } >>"$target_file"

  case "$environment" in
    staging)
      release_append_env_report_for_environment "$root" "$service" "$staging_old_sha" "$new_sha" staging "$target_file"
      ;;
    production)
      release_append_env_report_for_environment "$root" "$service" "$production_old_sha" "$new_sha" production "$target_file"
      ;;
    both)
      release_append_env_report_for_environment "$root" "$service" "$staging_old_sha" "$new_sha" staging "$target_file"
      release_append_env_report_for_environment "$root" "$service" "$production_old_sha" "$new_sha" production "$target_file"
      ;;
  esac
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

release_verify_postconditions() {
  local worktree_path=$1
  local branch=$2
  local commit_sha=$3
  local pr_url=$4
  local pr_title=$5
  local expected_files=$6
  local target_sha=$7
  local relpath
  local deployed_tag
  local remote_sha
  local actual_pr_url
  local actual_pr_title
  local actual_pr_branch
  local actual_pr_sha
  local actual_pr_files

  while IFS= read -r relpath; do
    [ -n "$relpath" ] || continue
    if [ ! -f "$worktree_path/$relpath" ]; then
      echo "Error: release postcondition missing values file: $relpath" >&2
      return 1
    fi
    deployed_tag=$(release_extract_tag_from_stream <"$worktree_path/$relpath" || true)
    if [ "$deployed_tag" != "$target_sha" ]; then
      echo "Error: release postcondition tag mismatch in $relpath" >&2
      return 1
    fi
  done < <(printf '%s\n' "$expected_files")

  if [ -n "$(git -C "$worktree_path" status --porcelain)" ]; then
    echo "Error: release postcondition found a dirty worktree" >&2
    return 1
  fi

  remote_sha=$(git -C "$worktree_path" ls-remote origin "refs/heads/$branch" | awk 'NR == 1 {print $1}')
  if [ "$remote_sha" != "$commit_sha" ]; then
    echo "Error: release postcondition remote branch does not match the release commit" >&2
    return 1
  fi

  actual_pr_url=$(gh pr view "$pr_url" --repo citizenshipper/ops --json url --jq '.url')
  actual_pr_title=$(gh pr view "$pr_url" --repo citizenshipper/ops --json title --jq '.title')
  actual_pr_branch=$(gh pr view "$pr_url" --repo citizenshipper/ops --json headRefName --jq '.headRefName')
  actual_pr_sha=$(gh pr view "$pr_url" --repo citizenshipper/ops --json headRefOid --jq '.headRefOid')
  actual_pr_files=$(gh pr view "$pr_url" --repo citizenshipper/ops --json files --jq '.files[].path' | sort)

  if [ "$actual_pr_url" != "$pr_url" ] || [ "$actual_pr_title" != "$pr_title" ]; then
    echo "Error: release postcondition PR identity does not match" >&2
    return 1
  fi
  if [ "$actual_pr_branch" != "$branch" ] || [ "$actual_pr_sha" != "$commit_sha" ]; then
    echo "Error: release postcondition PR head does not match the release commit" >&2
    return 1
  fi
  if [ "$actual_pr_files" != "$expected_files" ]; then
    echo "Error: release postcondition PR files do not match the intended release file set" >&2
    return 1
  fi
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

  release_append_env_report "$root" "$service" "$new_sha" "$environment" "$target_file" "$staging_old_sha" "$production_old_sha"
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
