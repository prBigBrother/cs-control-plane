Create one or more worktrees for an Engineering task.

Fast path:
- Do not delegate this command to an agent.
- Run `./bin/new-task` once per editable repo.
- If multiple repos are requested, run independent repo setup steps in parallel when the shell/tooling supports it.
- Return only created or reused worktree paths and any skipped read-only repos.

Usage:
`/task-start <repo...> <eng-id> [slug] [type]`

Rules:
- Accept one or more repo names followed by `ENG-<id>`, an optional slug, and an optional branch type.
- Default branch type to `feature`.
- If slug is omitted, pass the args through to `./bin/new-task`; it resolves an existing matching worktree or uses the fallback slug `task`.
- For each repo, run `./bin/new-task <repo> <eng-id> [slug] [type]`.
- If the repo is non-editable, report that it is read-only and skip it.
- If the worktree already exists, rerun `./bin/new-task` anyway so shared OpenCode config, env-file links, and `node_modules` links are repaired.
- Return the created or repaired worktree paths.
