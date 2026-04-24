Create a GitHub pull request for a repo worktree branch.

Fast path:
- Do not delegate this command to an agent.
- Run the script directly after the repo worktree has committed changes and passed validation.
- Default to a draft PR unless `ready` is explicitly requested.
- Generate the PR title and description from the task id, commits, and changed files.
- The PR title must start with `ENG-<id>:`. If no task id can be inferred, fail instead of creating a PR.

Usage:
`/pr-create [worktree-path] [draft|ready]`
`/pr-create [repo eng-id] [draft|ready]`
`/pr-create [repo eng-id slug] [draft|ready]`

Session:
- repo worktree with no repo args
- any session with an explicit worktree path
- control plane with explicit `repo eng-id`, when exactly one matching worktree exists
- control plane with explicit `repo eng-id slug`

Rules:
- Run `./bin/pr-create [worktree-path] [draft|ready]`, `./bin/pr-create [repo eng-id] [draft|ready]`, or `./bin/pr-create [repo eng-id slug] [draft|ready]`.
- Refuse to create a PR from `main`.
- Refuse dirty worktrees so uncommitted work is not left behind.
- Generate the PR title as `ENG-<id>: <latest commit subject or task slug>`.
- Generate the PR body with summary, changed files, validation checklist, and rollout notes.
- If an open PR already exists for the current branch, return that PR URL.
- Use `/release-prepare`, not `/pr-create`, for ops release tag updates.

Typical output:
- branch
- GitHub repository
- mode
- title
- PR URL
