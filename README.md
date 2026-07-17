# Citizenshipper Control Plane

This repository is the shared OpenCode control plane for the Citizenshipper multi-repo product.

It owns:
- shared OpenCode config, instructions, commands, agents, and skills
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
│   ├── skills/
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
4. Use the control plane when you need shared commands, subagents, skills, or bootstrap scripts.
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
./.opencode/bin/new-task icarus ENG-123 checkout-redesign feature
./.opencode/bin/new-task daedalus ENG-123 checkout-redesign feature
./.opencode/bin/new-task odin ENG-124
```

`bin/new-task` fetches the latest `origin/main` and creates new worktrees from that remote ref without checking out or pulling the base submodule worktree. This keeps `repos/*` from drifting just because a task was started.

`bin/new-task` also prepares local runtime assets from the base repo into the new worktree:
- real repo-root `node_modules` for repos with `package-lock.json`
- real package-local `node_modules` for packages with their own lockfile
- repo-root `.env*` files such as `.env` and `.env.local`
- `packages/**/.env*` files such as `.env` and `.env.local`

When a worktree has a lockfile and `node_modules` is missing or linked from the base checkout, `bin/new-task` runs `npm ci` inside the worktree. Pass `--no-install` to skip installs, or `--force-install` to reinstall even when local dependencies already exist.

Rerunning `bin/new-task` for an existing worktree repairs runtime links, verifies dependency freshness, and reinstalls the shared OpenCode config.

For Daedalus worktrees, `bin/new-task` also runs `npm run db:generate` after setup when Prisma is available, so the generated Prisma clients are current before implementation starts.

The slug is optional for task helpers. When omitted, existing worktrees are resolved by `ENG-<id>` if there is exactly one match.

Tracked env files already present in the worktree are left as-is; untracked local env files are symlinked from the base repo checkout.

Release helpers:

```bash
./bin/compare icarus staging
./bin/compare-curl 'curl https://api.example.test/v1/foo' 'curl https://api.example.test/v2/foo'
./bin/pr-release daedalus staging
./bin/pr-release daedalus,icarus production
./bin/new-release daedalus production
./bin/release-pr-body daedalus <full-sha> production
```

These scripts compare deployed SHAs, compare normalized curl responses, create isolated `ops` release worktrees, generate deterministic release PR bodies from the current release state, and automate end-to-end release PR creation.

`./bin/pr-release` accepts one service or comma-separated services without spaces and creates one release PR per service. It fails early if `repos/ops` has unrelated dirty state, so release PRs start from a clean base checkout.

Attach shared OpenCode config to a base repo or worktree:

```bash
./bin/install-local-opencode repos/icarus
./bin/install-local-opencode worktrees/icarus/ENG-123-checkout-redesign
./bin/install-local-opencode worktrees/daedalus/ENG-456-migration-cutover migration
```

The default profile is `engineering`, which loads shared engineering instructions. The only optional profile is:
- `migration`: engineering plus migration rules

The four standalone `opencode*.json` profiles are generated from `config/opencode-profiles.json`. Run `./bin/opencode-profiles` after source changes; validation checks drift and the current OpenCode parser.

Control-plane installs default to Manager. Repo and worktree installs default to Explorer so repo-local sessions start in read-only investigation mode. The built-in Build agent is disabled in all shared profiles.

Linear and Datadog MCP servers are configured for per-agent use. Their tools are hidden globally and exposed through `linear-operator` and `datadog-investigator`. Authenticate once when needed:

```bash
opencode mcp auth linear
opencode mcp auth datadog
```

Use the Datadog endpoint for your site if the default US1 endpoint is not correct.

Agent visibility is installed separately:
- `repo`: common agents plus Explorer, Implementer, Validator
- `control-plane`: common agents plus Manager, Auditor, Release
- `full`: common agents plus all project agents

Repo and worktree sessions also receive the shared helper scripts at `./.opencode/bin`, so slash commands can run deterministic helpers without locating the control-plane checkout.

The installer also links the control-plane `.envrc` into the target root and adds `/.envrc` to that repo's local git exclude file. This makes direnv-backed credentials and local service endpoints available when shells or tools start directly inside a repo or worktree. New targets still need the normal one-time `direnv allow`.

If OpenCode shows a base repo session under `.git/modules/repos/<repo>` instead of `repos/<repo>`, embed the submodule Git directories locally:

```bash
./bin/repair-submodule-gitdirs
```

This embeds each initialized submodule Git directory at `repos/<repo>/.git` and retargets existing linked worktree gitfiles.

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

Preview and bulk clean stale task worktrees:

```bash
./.opencode/bin/cleanup-worktrees
./.opencode/bin/cleanup-worktrees --repo icarus --apply
```

The bulk cleanup helper previews by default, removes clean matching task worktrees only with `--apply`, and prompts before force-removing dirty worktrees in an interactive shell.

Create a compact handoff brief for agents:

```bash
./bin/session-brief worktrees/icarus/ENG-123-checkout-redesign
```

Check workspace health:

```bash
./bin/workspace-doctor
```

This reports control-plane dirtiness, submodule pointer drift, worktree status, runtime link state, and installed agent counts.

Refresh all base submodule checkouts to `origin/main`:

```bash
./bin/update-base-repos --dry-run
./bin/update-base-repos --force
```

This is intended for keeping `repos/*` base checkouts current. It hard-resets each submodule to `origin/main`; add `--stage-pointers` when you also want to commit the updated control-plane gitlinks.

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

For LAN access from another MacBook on the same network, keep OpenChamber bound to all interfaces and keep the managed OpenCode server bound to localhost:

```bash
export OPENCHAMBER_HOST=0.0.0.0
export OPENCHAMBER_PORT=9999
export OPENCHAMBER_OPENCODE_HOSTNAME=127.0.0.1
```

Then run `just up` and open the reported `Network access` URL from the second MacBook, for example `http://192.168.100.23:9999`. OpenCode itself should only be exposed directly with `opencode serve --hostname 0.0.0.0 --port 4096` when a remote `opencode attach` workflow is explicitly needed, and it must be protected with `OPENCODE_SERVER_PASSWORD`.

Slim is only needed for the local hostname route. For direct LAN access by IP, set `OPENCHAMBER_SKIP_SLIM=1` to avoid macOS `sudo` prompts for packet filter rules.

Validate control-plane scripts and command docs:

```bash
./bin/validate-control-plane
```

Create an app repo PR from a committed worktree branch:

```bash
./bin/pr-create worktrees/icarus/ENG-123-checkout-redesign
```

`bin/pr-create` runs root `lint` and `typecheck` package scripts when present before it pushes the branch. Use `PR_SKIP_VALIDATION=1` only for repos without an applicable local validation path.

Review a GitHub pull request:

```bash
./bin/pr-review collect https://github.com/owner/repo/pull/123
./bin/pr-review submit --approved https://github.com/owner/repo/pull/123 tmp/pr-review-owner-repo-123/findings.json
```

The shared `/pr-review <pr-url>` command wraps this flow, classifies findings as critical, medium, or light, and requires explicit approval before submission. It refuses to post comments or reviews on your own PRs.

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
