Create one or more worktrees for an Engineering task.

Usage:
`/task-start <repo...> <eng-id> <slug> [type]`

Rules:
- Accept one or more repo names followed by `ENG-<id>`, a slug, and an optional branch type.
- Default branch type to `feature`.
- For each repo, run `./bin/new-task <repo> <eng-id> <slug> <type>`.
- If the repo is non-editable, report that it is read-only and skip it.
- Return the created worktree paths.
