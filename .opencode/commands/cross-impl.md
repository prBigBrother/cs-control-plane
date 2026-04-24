Coordinate a cross-repo implementation task.

Delegation:
- Immediately use the `Task` tool to delegate to the `orchestrator` agent.
- Pass the full slash-command invocation as the task prompt so the agent can coordinate repo explorers and repo implementers as needed.
- Return the agent result directly.

Usage:
`/cross-impl <eng-id> <goal>`

Rules:
- Break the goal into repo-scoped tasks.
- Keep one editing owner per repo.
- Use repo explorers before repo implementers if boundaries are unclear.
- Return a short repo-by-repo plan with worktree targets.
