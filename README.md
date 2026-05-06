# Citizenshipper Control Plane

This repository is the shared OpenCode control plane for the Citizenshipper multi-repo product.

It owns:
- shared OpenCode config, instructions, commands, and agents
- submodule references to the product repositories
- worktree bootstrap and cleanup scripts
- shared orchestration helpers

It does not own product code. Active edits should happen in repo-specific worktrees under `worktrees/`.

## Layout

```text
.
├── .opencode/
│   ├── agents/
│   ├── agent-packs/
│   ├── commands/
│   ├── plugins/
│   └── tools/
├── bin/
├── instructions/
├── repos/
└── worktrees/
```

## Operating Model

1. Keep the canonical base checkouts in `repos/` as git submodules.
2. Create per-task worktrees in `worktrees/<repo>/ENG-<id>-<slug>/`.
3. Open OpenCode directly in each worktree for implementation.
4. Use the control plane when you need shared commands, subagents, or bootstrap scripts.
5. Use `./bin/install-local-opencode <path>` to attach the shared OpenCode config to any repo or worktree without committing personal config files.

## Bootstrap

Initialize submodules:

```bash
./bin/add-submodules
./bin/bootstrap
```

`bin/bootstrap` initializes the control-plane directories and runs `npm ci` in the Node repos that have a `package-lock.json` (`icarus`, `daedalus`, `olympus`, `odin`, and `dinah`). It skips `ops`.

Create worktrees:

```bash
./bin/new-task icarus ENG-123 checkout-redesign feature
./bin/new-task daedalus ENG-123 checkout-redesign feature
./bin/new-task odin ENG-124
```

`bin/new-task` also links local runtime assets from the base repo into the new worktree when they exist:
- repo-root `node_modules`
- `packages/**/node_modules`
- repo-root `.env*` files such as `.env` and `.env.local`
- `packages/**/.env*` files such as `.env` and `.env.local`

Rerunning `bin/new-task` for an existing worktree repairs these links and reinstalls the shared OpenCode config.

The slug is optional for task helpers. When omitted, existing worktrees are resolved by `ENG-<id>` if there is exactly one match.

`bin/new-task` fetches `origin/main` and creates new worktrees from that remote ref without checking out or pulling the base submodule worktree. This keeps `repos/*` from drifting just because a task was started.

Tracked env files already present in the worktree are left as-is; untracked local env files are symlinked from the base repo checkout.

Release helpers:

```bash
./bin/compare icarus staging
./bin/compare-curl 'curl https://api.example.test/v1/foo' 'curl https://api.example.test/v2/foo'
./bin/release-prepare daedalus staging
./bin/new-release daedalus production
./bin/release-pr-body daedalus <full-sha> production
```

These scripts compare deployed SHAs, compare normalized curl responses, create isolated `ops` release worktrees, generate deterministic release PR bodies from the current release state, and automate end-to-end release PR creation.

`./bin/release-prepare` fails early if `repos/ops` has unrelated dirty state, so release PRs start from a clean base checkout.

Attach shared OpenCode config to a base repo or worktree:

```bash
./bin/install-local-opencode repos/icarus
./bin/install-local-opencode worktrees/icarus/ENG-123-checkout-redesign
./bin/install-local-opencode worktrees/daedalus/ENG-456-migration-cutover migration
./bin/install-local-opencode worktrees/ops/ENG-789-release release
./bin/install-local-opencode repos/icarus full
```

The default profile is `engineering`, which keeps remote MCPs disabled and loads only shared engineering instructions. Optional profiles are:
- `migration`: engineering plus migration rules
- `release`: engineering plus release rules
- `external`: engineering plus remote MCP integrations
- `full`: all shared rules plus remote MCP integrations, matching the previous broad setup

Agent visibility is installed separately:
- `repo`: Explorer, Implementer, Validator
- `control-plane`: Manager, Auditor, Release
- `full`: all project agents

Repo and worktree sessions also receive the shared helper scripts at `./.opencode/bin`, so slash commands can run deterministic helpers without locating the control-plane checkout.

Use the third argument to choose an agent set explicitly:

```bash
./bin/install-local-opencode . engineering control-plane
./bin/install-local-opencode worktrees/icarus/ENG-123-checkout-redesign engineering repo
```

Show repo profiles:

```bash
./bin/repo-profile icarus
./bin/repo-profile dinah
```

Map worktrees:

```bash
./bin/worktree-map icarus ENG-123 checkout-redesign
```

Create a compact handoff brief for agents:

```bash
./bin/session-brief worktrees/icarus/ENG-123-checkout-redesign
```

Check workspace health:

```bash
./bin/workspace-doctor
```

This reports control-plane dirtiness, submodule pointer drift, worktree status, runtime link state, and installed agent counts.

Start or stop the local OpenChamber + Slim route:

```bash
just up
just status
just down
```

Equivalent script calls:

```bash
OPENCHAMBER_PASSWORD=... ./bin/openchamber-slim up
./bin/openchamber-slim status
./bin/openchamber-slim down
```

`just up` loads root env config, starts OpenChamber on port `9999` when it is not already running there, then ensures Slim exposes `opencode.test` to port `9999` from `.slim.yaml`.

Validate control-plane scripts and command docs:

```bash
./bin/validate-control-plane
```

Create an app repo PR from a committed worktree branch:

```bash
./bin/pr-create worktrees/icarus/ENG-123-checkout-redesign
```

Review a GitHub pull request:

```bash
./bin/pr-review collect https://github.com/owner/repo/pull/123
./bin/pr-review submit https://github.com/owner/repo/pull/123 tmp/pr-review-owner-repo-123/findings.json
```

The shared `/pr-review <pr-url>` command wraps this flow, classifies findings as critical, medium, or light, and refuses to post comments or reviews on your own PRs.

## OpenCode Session Model

- Implementation sessions should run inside a repo worktree.
- The control plane repo is for shared policy, orchestration, and maintenance.
- `dinah` participates in migration and audit workflows as read-only. It does not get editable worktrees.
- Deterministic command workflows should run scripts directly; use subagents for repo-scoped discovery, implementation, validation, and cross-repo planning.
- Project agents use concise names (`manager`, `explorer`, `implementer`, `validator`, `auditor`, `release`) and are installed by session type for Tab switching.
- Control-plane sessions should show only Manager, Auditor, and Release.
- Repo worktree sessions should show only Explorer, Implementer, and Validator.
- Run setup, cleanup, release, migration audit, and cross-repo orchestration commands from the control-plane session.
- Run implementation, repo-local validation, debugging, and task-branch git inspection from the repo worktree session.

## Guides

See [docs/agents.md](docs/agents.md) for the current shared agents, when to use each one, and how they fit into the multi-session workflow.

See [docs/commands.md](docs/commands.md) for the current shared slash commands, their intended use, and which ones are backed by `bin/` scripts.

See [docs/development-cycle.md](docs/development-cycle.md) for the full development cycle from task intake through release preparation.
