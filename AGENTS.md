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

## Commands And Agents

- Shared OpenCode commands and agents are defined under `.opencode/`.
- Use `bin/install-local-opencode` to expose the shared control-plane config inside repo-local sessions without committing personal OpenCode files.
- Repo-specific rules should stay in each repo's local `AGENTS.md`.
- Shared behavior should be referenced through repo `opencode.json` files, not duplicated.
