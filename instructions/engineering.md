# Engineering Instructions

- Branch format: `<feature|bug|hotfix|release>/ENG-<id>/<slug>`
- Worktree path format: `worktrees/<repo>/ENG-<id>-<slug>/`
- Base submodule checkouts in `repos/*` should stay clean and aligned to `main`.
- Create worktrees from `repos/*`, not from other worktrees.
- Keep repo validation scoped to the repo where code changed.
- Use repo-local `AGENTS.md` files for exact build, lint, typecheck, and test rules.
- Start repo-scoped subagents with `./bin/session-brief <worktree>` when they need only compact repo state.
- For cross-repo work, explore independent repos in parallel, then assign at most one editing agent per repo worktree.
