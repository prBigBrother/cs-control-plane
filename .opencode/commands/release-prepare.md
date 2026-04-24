Prepare a release in the `ops` repo based on app repo heads.

Delegation:
- Immediately use the `Task` tool to delegate to the `release-manager` agent.
- Pass the full slash-command invocation as the task prompt so the agent receives the original args unchanged.
- Return the agent result directly.

Usage:
`/release-prepare <service> [environment]`

Rules:
- Operate through the `ops` worktree only.
- Run `./bin/release-prepare <service> [environment]`.
- Fail if `repos/ops` is dirty before the release worktree is created.
- Return the script output directly.
