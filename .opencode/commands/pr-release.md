---
description: Prepare ops release PRs from app repository heads.
---

Usage: `/pr-release <service[,service...]> [environment]`

Run `./.opencode/bin/pr-release <services> [environment]` directly. Operate only through an `ops` worktree, one PR per comma-separated service. Stop if `repos/ops` is dirty. Preserve the generated environment-parameter gate and return the helper's compact Markdown with worktree, target SHA, changed values, commit, postcondition validation, and PR link. Use Release only to investigate an exceptional helper failure.
