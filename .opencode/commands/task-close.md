Close a task by validating state, persisting durable notes, and cleaning up worktrees.

Delegation:
- Immediately use the `Task` tool to delegate to the `orchestrator` agent.
- Pass the full slash-command invocation as the task prompt so the agent receives the original args unchanged.
- Return the agent result directly.

Usage:
`/task-close <repo> <eng-id> <slug>`

Rules:
- Resolve the worktree path.
- Run `./bin/cleanup-task <repo> <eng-id> <slug>`.
