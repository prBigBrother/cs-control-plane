resolve_existing_worktree_slug() {
  local root="$1"
  local repo="$2"
  local eng_id="$3"
  local worktree_root="$root/worktrees/$repo"
  local matches=()
  local match

  if [ ! -d "$worktree_root" ]; then
    return 1
  fi

  while IFS= read -r match; do
    matches+=("$match")
  done < <(find "$worktree_root" -mindepth 1 -maxdepth 1 -type d -name "$eng_id-*" | sort)

  if [ "${#matches[@]}" -eq 1 ]; then
    basename "${matches[0]}" | sed -E "s/^$eng_id-//"
    return 0
  fi

  if [ "${#matches[@]}" -gt 1 ]; then
    echo "Error: multiple worktrees match $repo $eng_id; pass the slug explicitly." >&2
    printf '%s\n' "${matches[@]#$root/}" >&2
    return 2
  fi

  return 1
}

slugify_task_text() {
  local value="$*"
  printf '%s' "$value" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g'
}
