---
description: Prepare an ops release PR from an app repo head.
---

Usage: `/pr-release <service[,service...]> [environment]`

Run `./.opencode/bin/pr-release <service[,service...]> [environment]`.

Rules:
- Use the Release agent when available; otherwise keep the flow script-driven.
- Operate through the `ops` worktree only.
- Accept comma-separated services without spaces, for example `/pr-release daedalus,icarus production`.
- Create one release PR per service.
- Fail if `repos/ops` is dirty before creating the release worktree.
- Preserve the generated environment-parameter check in the PR body.
- Return the script Markdown summary directly.
