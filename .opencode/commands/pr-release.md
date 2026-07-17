---
description: Prepare ops release PRs from app repository heads.
---

Usage: `/pr-release <service[,service...]> [environment]`

Use the Release agent when available, then run `./.opencode/bin/pr-release <services> [environment]`. Operate only through an `ops` worktree, one PR per comma-separated service. Stop if `repos/ops` is dirty. Preserve the generated environment-parameter gate and return the helper's compact Markdown with worktree, target SHA, changed values, commit, validation, and PR link.
