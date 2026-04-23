# Release Instructions

- Release work should happen in the `ops` repo worktree only.
- Release inputs come from the relevant app repo `origin/main` HEAD commit SHA.
- Keep release logic scriptable and deterministic.
- Do not couple feature implementation worktrees to release worktrees.
- Use the full commit SHA as the image tag. Never use short SHAs.
- Update `ops/k8s/<service>/values.<environment>.yaml` for the requested environment.
- Release PR titles must match the app HEAD commit subject exactly.
- Release commits should use `release <service names> on <envs>, <short description>`.
