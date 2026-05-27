---
description: Report compact control-plane workspace health.
---

Usage: `/workspace-status`

Run `./bin/workspace-doctor`.

Rules:
- Do not delegate.
- Report dirty control-plane files, submodule pointer drift, worktree dirty state, runtime links, and installed agents.
- Keep output compact; do not expand full logs unless asked.
