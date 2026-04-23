Close a task by validating state, persisting durable notes, and cleaning up worktrees.

Usage:
`/task-close <repo> <eng-id> <slug>`

Rules:
- Resolve the worktree path.
- Summarize durable facts for memory.
- Run `./bin/cleanup-task <repo> <eng-id> <slug>`.
