Close a task by validating state, persisting durable notes, and cleaning up worktrees.

Fast path:
- Do not delegate this command to an agent unless cleanup fails and investigation is needed.
- Resolve the worktree path locally and run the cleanup script directly.
- Return the cleanup result and any branch/worktree state that still needs attention.

Usage:
`/task-close <repo> <eng-id> <slug>`

Rules:
- Resolve the worktree path.
- Run `./bin/cleanup-task <repo> <eng-id> <slug>`.
