# Control-Plane Tools

This directory is reserved for OpenCode custom tools once the local tool format is standardized.

Current deterministic helpers live in `bin/` and are exposed through slash commands:
- `bin/session-brief` via `/session-brief`
- `bin/worktree-map` via `/task-map`
- `bin/new-task` via `/task-start`
- `bin/cleanup-task` via `/task-close`
- `bin/compare` via `/compare`
- `bin/pr-comments` via `/pr-comments`
- `bin/release-prepare` via `/release-prepare`

Prefer these script-backed paths for repetitive work so agents do not spend tokens rediscovering basic repo state.

Agent visibility is handled through `.opencode/agent-packs/` and `bin/install-local-opencode`, not this directory.
