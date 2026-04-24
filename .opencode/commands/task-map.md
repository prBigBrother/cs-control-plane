Show the worktree mapping for a repo task.

Delegation:
- Immediately use the `Task` tool to delegate to the `orchestrator` agent.
- Pass the full slash-command invocation as the task prompt so the agent receives the original args unchanged.
- Return the agent result directly.

Usage:
`/task-map <repo> <eng-id> <slug>`

Rules:
- Run `./bin/worktree-map <repo> <eng-id> <slug>`.
- Return the resolved path and whether the repo is editable.
