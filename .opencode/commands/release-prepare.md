---
description: Prepare an ops release PR from an app repo head.
---

Usage: `/release-prepare <service> [environment]`

Run `./bin/release-prepare <service> [environment]`.

Rules:
- Use the Release agent when available; otherwise keep the flow script-driven.
- Operate through the `ops` worktree only.
- Fail if `repos/ops` is dirty before creating the release worktree.
- Preserve the generated environment-parameter check in the PR body.
- Return the script Markdown summary directly.
