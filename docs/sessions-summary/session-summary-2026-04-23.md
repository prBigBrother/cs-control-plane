# Session Summary: Control Plane Bootstrap

This file captures the current state of the Citizenshipper control-plane project after the initial bootstrap and refinement session.

## What Was Built

- Initialized a dedicated git repo at `<control-plane-root>`
- Added product repos as submodules under `repos/`:
  - `icarus`
  - `daedalus`
  - `ops`
  - `olympus`
  - `odin`
  - `dinah`
- Set up the control-plane layout:
  - shared OpenCode config in `opencode.json`
  - shared instructions in `instructions/`
  - shared agents and commands in `.opencode/`
  - shared helper scripts in `bin/`
  - internal helper modules in `lib/`
  - worktree area in `worktrees/`

## Operating Model

- Do not use the control-plane repo as the main implementation session.
- Open OpenCode in repo worktrees for actual coding.
- Use the control-plane repo for:
  - shared rules and instructions
  - worktree bootstrap and cleanup
  - release helpers
  - cross-repo orchestration

## Shared OpenCode Setup

- Base repos and new worktrees can receive shared OpenCode config via:
  - `bin/install-local-opencode <path>`
- `bin/new-task` automatically installs the shared OpenCode config into the created worktree.
- Shared config is symlinked into repo/worktree sessions using:
  - `opencode.json`
  - `.opencode/`

## Worktree Behavior

- Standard task worktrees live under:
  - `worktrees/<repo>/ENG-<id>-<slug>`
- Release worktrees for `ops` live under:
  - `worktrees/ops/release-<service>-<environment>-head-image`
  - or `worktrees/ops/release-<service>-head-image`
- `dinah` is intentionally read-only in the control plane and does not get editable worktrees.

## Bootstrap And Linking Rules

`bin/bootstrap`:
- initializes repo directories
- runs `npm ci` in Node repos with `package-lock.json`
- skips `ops`

`bin/new-task`:
- refreshes `origin/main`
- creates the git worktree
- copies repo-local `AGENTS.md`
- installs shared OpenCode config into the new worktree
- links runtime assets from the base repo when present:
  - repo-root `node_modules`
  - `packages/**/node_modules`
  - repo-root `.env*`
  - `packages/**/.env*`

Important nuance:
- tracked `.env` files already present in the new worktree remain normal files
- untracked local `.env` and `.env.local` files are symlinked from the base repo

## Promoted Workspace Helpers

The important reusable parts of the old `daedalus-dinnah-migration` workspace were moved into the control plane:

- `bin/compare`
- `bin/new-release`
- `bin/release-pr-body`
- `bin/pr-comments`

Related command docs were added under:
- `.opencode/commands/compare.md`
- `.opencode/commands/pr-comments.md`

## Shared Agents

Current shared agents are documented in:
- `docs/agents.md`

Current agent set:
- `orchestrator`
- `repo-explorer`
- `repo-implementer`
- `migration-auditor`
- `release-manager`

## Migration And Release Rules Added

Important migration behavior promoted into shared instructions:
- Dinah is legacy and read-only
- migrations should follow Phase 1 / Phase 2 structure
- Phase 1 should dual-write from Daedalus
- Icarus feature flags must be reflected in:
  - `packages/icarus/.env.sample.staging`
  - `packages/icarus/scripts/env.template.js`

Important release behavior promoted into shared instructions:
- release changes happen in `ops` only
- release inputs come from app `origin/main`
- use full SHAs only
- release PR titles should match app HEAD commit subject

## Memory Status

All memory-related scaffolding was removed for now.

Removed:
- memory instruction file
- memory agent
- Mem0 placeholder plugin
- memory helper script
- memory env placeholders

Current state:
- there is no active memory integration
- future memory work is intentionally deferred

## Config Fixes Made

An invalid top-level `tool` key in `opencode.json` was removed.

Also:
- helper scripts were moved out of `.opencode/tools/`
- internal helper modules now live in `lib/`

This matters because `.opencode/tools/` was being treated as OpenCode custom tool definitions, which caused config/runtime problems.

## MCP Servers In Control Plane

Moved into shared `opencode.json`:
- `composio`
- `figma`
- `slack`
- `tavily`
- `storyblok`

Secrets were not copied directly into git-tracked config.

Instead:
- `TAVILY_API_KEY`
- `STORYBLOK_MCP_TOKEN`

are expected through environment variable substitution.

## Documentation Added

- `README.md` updated with bootstrap, worktree, and release-helper guidance
- `docs/agents.md` added to explain when to use each shared agent

## Commits Created In This Session

Control-plane commits created during this session:

- `29912c2` — `Scaffold OpenCode multi-repo control plane`
- `88e9e52` — `Add MCP servers and improve worktree bootstrap`
- `3aee5cc` — `Promote core workspace workflows into control plane`
- `e042a59` — `Document control-plane agents`

## Important Outstanding State

- The control-plane repo itself is in good shape for continued work.
- The configured remote is:
  - `git@github.com:prBigBrother/cs-control-plane.git`
- Pushes to that personal remote were blocked by policy in this environment, so pushes must be performed manually.
- There is still unrelated dirty state inside the `repos/ops` submodule working tree.
  - This was not modified or cleaned up in this session.

## Recommended Next Steps

1. Open the control-plane repo and read:
   - `README.md`
   - `docs/agents.md`
2. Start using:
   - `bin/new-task`
   - `bin/new-release`
   - `bin/compare`
   - `bin/release-pr-body`
3. Open separate OpenCode sessions inside repo worktrees for implementation.
4. Decide later whether to add a memory system.
5. Push the control-plane repo manually from your shell if needed.

## Manual Push Command

```bash
git -C <control-plane-root> push origin main
```
