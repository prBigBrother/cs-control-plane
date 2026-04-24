Create one or more worktrees for an Engineering task.

Delegation:
- Immediately use the `Task` tool to delegate to the `orchestrator` agent.
- Pass the full slash-command invocation as the task prompt so the agent receives the original args unchanged.
- Return the agent result directly.

Usage:
`/task-start <repo...> <eng-id> <slug> [type]`

Rules:
- Accept one or more repo names followed by `ENG-<id>`, a slug, and an optional branch type.
- Default branch type to `feature`.
- For each repo, run `./bin/new-task <repo> <eng-id> <slug> <type>`.
- If the repo is non-editable, report that it is read-only and skip it.
- Return the created worktree paths.
