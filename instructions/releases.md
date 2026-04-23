# Release Instructions

- Release work should happen in the `ops` repo worktree only.
- Release inputs come from the relevant app repo `main` HEAD commit SHA.
- Keep release logic scriptable and deterministic.
- Do not couple feature implementation worktrees to release worktrees.
