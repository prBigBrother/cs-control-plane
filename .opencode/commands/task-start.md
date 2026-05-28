---
description: Create or repair one or more Engineering task worktrees.
---

Usage: `/task-start <repo...> <eng-id> [slug] [type]`

Run `./.opencode/bin/new-task <repo> <eng-id> [slug] [type]` once per editable repo.

Rules:
- Do not delegate.
- Default branch type to `feature`.
- Skip `dinah` as read-only.
- If slug is omitted, let the script resolve an existing worktree or use `task`.
- Rerun the script for existing worktrees so shared OpenCode config and runtime links are repaired.
- Return only created/reused worktree paths and skipped repos.
