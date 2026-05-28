# Control-Plane Tools

This directory is reserved for OpenCode custom tools once the local tool format is standardized.

Current deterministic helpers live in `bin/`, and OpenCode sessions call them through `./.opencode/bin/`:
- `./.opencode/bin/session-brief` via `/session-brief`
- `./.opencode/bin/worktree-map` via `/task-map`
- `./.opencode/bin/new-task` via `/task-start`
- `./.opencode/bin/cleanup-task` via `/task-close`
- `./.opencode/bin/compare` via `/compare`
- `./.opencode/bin/compare-curl` via `/compare-curl`
- `./.opencode/bin/knowledge-bootstrap` via `/knowledge-bootstrap`
- `./.opencode/bin/knowledge-query` via `/knowledge`
- `./.opencode/bin/pr-comments` via `/pr-comments`
- `./.opencode/bin/pr-review` via `/pr-review`
- `./.opencode/bin/release-prepare` via `/release-prepare`
- `./.opencode/bin/workspace-doctor` via `/workspace-status`

Prefer these script-backed paths for repetitive work so agents do not spend tokens rediscovering basic repo state.

Agent visibility is handled through `.opencode/agent-packs/` and `bin/install-local-opencode`, not this directory.
