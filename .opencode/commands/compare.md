Compare the currently deployed SHA in `ops` against a target service SHA.

Delegation:
- Immediately use the `Task` tool to delegate to the `orchestrator` agent.
- Pass the full slash-command invocation as the task prompt so the agent receives the original args unchanged.
- Return the agent result directly.

Usage:
`/compare <service> <environment> [target-sha]`

Rules:
- Run `./bin/compare <service> <environment> [target-sha]`.
- Accept `prod` as an alias for `production`.
- Return the script output directly.
