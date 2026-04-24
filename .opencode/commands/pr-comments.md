Fetch PR description, comments, and review threads from GitHub.

Delegation:
- Immediately use the `Task` tool to delegate to the `orchestrator` agent.
- Pass the full slash-command invocation as the task prompt so the agent receives the original args unchanged.
- Return the agent result directly.

Usage:
`/pr-comments <repo> <pr-number>`

Rules:
- Accept repo as `ops` or `citizenshipper/ops`.
- Run `./bin/pr-comments <repo> <pr-number>`.
- Return the script output directly.
