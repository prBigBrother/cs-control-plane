---
description: Create or repair one or more Engineering task worktrees.
---

Usage: `/task-start [--no-install] [--force-install] <repo...> <eng-id> [slug] [type]`

Run `./.opencode/bin/new-task [--no-install] [--force-install] <repo> <eng-id> [slug] [type]` once per editable repo.

Rules:
- Do not delegate.
- Default branch type to `feature`.
- Skip `dinah` as read-only.
- If slug is omitted, let the script resolve an existing worktree or use `task`.
- Rerun the script for existing worktrees so shared OpenCode config, env links, and dependency state are repaired.
- Let the script fetch `origin/main` before creating the worktree.
- For lockfile repos, let the script install real worktree `node_modules`; do not rely on base-checkout symlinks.
- Use `--no-install` only when explicitly asked to skip dependency installation.
- Use `--force-install` when dependency generation needs a fresh local install.
- For Daedalus, let the script run `npm run db:generate` after dependency prep when Prisma is available.
- Return only created/reused worktree paths and skipped repos.
