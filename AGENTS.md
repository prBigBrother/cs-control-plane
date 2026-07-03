# Control Plane Rules

This repository is a shared OpenCode control plane for multiple product repositories.

## Scope

- Shared config, instructions, commands, agents, and bootstrap scripts live here.
- Product repositories are mounted as submodules in `repos/`.
- Product changes must be made in repo-specific worktrees under `worktrees/`.

## Session Model

- Open OpenCode in a worktree for implementation.
- Use this control plane repo to maintain shared OpenCode behavior and cross-repo tooling.
- Do not edit application code directly in `repos/*`.

## Repository Roles

- `icarus`, `daedalus`, `ops`, `olympus`, and `odin` are editable through worktrees.
- `dinah` is read-only for shared workflows and migration audits.

## Worktrees

- Worktree path format: `worktrees/<repo>/ENG-<id>-<slug>/`
- Branch format: `<feature|bug|hotfix|release>/ENG-<id>/<slug>`
- One repo gets one active worktree per task stream.
- If a repo needs parallel streams, create separate worktrees with distinct slugs.

## Worktree Bootstrap

- Use `./.opencode/bin/new-task [--no-install] [--force-install] <repo> <eng-id> [slug] [type]` or `/task-start` to create or repair task worktrees.
- The helper fetches the latest `origin/main` and creates new worktrees from that remote ref without pulling or checking out the base repo under `repos/*`.
- For lockfile repos, the helper uses real worktree `node_modules` and runs `npm ci` when dependencies are missing or linked from the base checkout.
- Use `--force-install` when an existing worktree needs fresh local dependencies.
- Daedalus worktrees run `npm run db:generate` after dependency prep when Prisma is available.
- Use `/task-cleanup` or `./.opencode/bin/cleanup-worktrees` to preview or bulk-clean stale task worktrees; dirty worktrees require an explicit force decision.

## Commands And Agents

- Shared OpenCode commands, agents, and skills are defined under `.opencode/`.
- Use `bin/install-local-opencode` to expose the shared control-plane config inside repo-local sessions without committing personal OpenCode files.
- Control-plane sessions default to Manager; repo/worktree sessions default to Explorer.
- The built-in Build agent is disabled in shared OpenCode profiles.
- Repo-specific rules should stay in each repo's local `AGENTS.md`.
- Shared behavior should be referenced through repo `opencode.json` files, not duplicated.
