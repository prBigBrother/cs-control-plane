---
description: Create or repair Engineering task worktrees.
---

Usage: `/task-start [--no-install] [--force-install] <repo...> <eng-id> [slug] [type]`

For each editable repo, run `./.opencode/bin/new-task [flags] <repo> <eng-id> [slug] [type]`; skip read-only `dinah`. The helper owns naming, `origin/main` fetch, OpenCode/env repair, local lockfile installs, and Daedalus Prisma generation. Default type is `feature`; omit slug when unresolved. Use `--no-install` only when requested and `--force-install` for fresh dependencies. Return created/reused paths and skipped repos.
