Show the worktree mapping for a repo task.

Fast path:
- Do not delegate this command to an agent.
- Run the script directly and return the resolved path plus editable/read-only status.

Usage:
`/task-map <repo> <eng-id> <slug>`

Rules:
- Run `./bin/worktree-map <repo> <eng-id> <slug>`.
- Return the resolved path and whether the repo is editable.
