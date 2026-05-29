# Using Control-Plane Commands

This document explains the current shared slash commands in the control plane, when to use them, and which ones are backed by `bin/` scripts.

## Core Rule

- Use control-plane commands for shared orchestration, worktree bootstrap, release helpers, and review utilities.
- Prefer running implementation work inside the target repo worktree, not from the control-plane repo.
- When a command maps to a `bin/` script, prefer the script-backed path so behavior stays deterministic.
- Do not delegate simple script-backed commands to agents. Delegate only when planning, investigation, implementation, validation, or release judgment is required.

## Where Commands Belong

### Control-plane session only

Run these from the control-plane repo root because they create, remove, coordinate, or release shared worktrees:

- `/task-start`
- `/task-map`
- `/task-close`
- `/task-cleanup`
- `/cross-impl`
- `/migration-audit`
- `/compare`
- `/compare-curl`
- `/knowledge-bootstrap`
- `/release-prepare`
- `/workspace-status`

### Repo worktree session

Run these from `worktrees/<repo>/ENG-<id>-<slug>/` while doing repo-local implementation:

- repo-local build, lint, typecheck, and test commands from that repo's `AGENTS.md`
- repo-local debugging commands
- repo-local git inspection for the active task branch
- `/session-brief` when you want a compact summary of the current repo session
- `/pr-create [draft|ready]` after committing validated changes

### Either session

These are safe in either place when the target repo/path is explicit or the helper is installed in the repo session:

- `/pr-comments <repo> <pr-number>`
- `/pr-review <pr-url>`
- `/knowledge-bootstrap [--dry-run|--extract] [--smoke]`
- `/knowledge <question>`
- `/session-brief [repo-or-worktree-path]`
- `/pr-create [worktree-path] [draft|ready]`
- `/pr-create [repo eng-id] [draft|ready]`
- `/pr-create [repo eng-id slug] [draft|ready]`

When in doubt, use the control plane for setup, cleanup, release, and cross-repo coordination; use the repo worktree for code changes and validation.

## Command List

### `/task-start`

Session:
- control-plane only

Purpose:
- create one or more repo worktrees for an engineering task
- apply the standard branch and worktree naming rules
- install shared OpenCode config into each new worktree
- prepare worktree dependencies from matching base installs or `npm ci`

Use it when:
- you are starting work in one or more editable repos
- you want the standard `worktrees/<repo>/ENG-<id>-<slug>` layout
- you want repo-local `AGENTS.md` copied into the worktree when present

Backed by:
- `./.opencode/bin/new-task`

Usage:
- `/task-start [--no-install] [--force-install] <repo...> <eng-id> [slug] [type]`

Typical output:
- created worktree paths
- dependency link/install status
- read-only skip notice for non-editable repos such as `dinah`
- no agent transcript

Important behavior:
- rerunning `/task-start` for an existing worktree repairs shared OpenCode config, env-file links, and dependency state
- slug is optional; when omitted, an existing matching worktree is reused if there is exactly one match, otherwise new worktrees use the fallback slug `task`
- new worktrees are created from the latest fetched `origin/main` without checking out or pulling the base repo under `repos/*`
- lockfile repos use real worktree `node_modules`, not base-checkout symlinks
- when a lockfile worktree has missing or linked dependencies, the helper runs `npm ci` inside the worktree unless `--no-install` is passed
- `--force-install` runs `npm ci` even when a local worktree `node_modules` directory already exists
- worktrees receive the repo agent set: Explorer, Implementer, and Validator
- Daedalus worktrees run `npm run db:generate` after setup when Prisma is available

### `/task-map`

Session:
- control-plane only

Purpose:
- resolve the expected worktree path for a repo task
- show whether the repo is editable in this control plane

Use it when:
- you need to confirm the canonical path for a task worktree
- you are coordinating work across sessions and need a stable target path

Backed by:
- `./.opencode/bin/worktree-map`

Usage:
- `/task-map <repo> <eng-id> [slug]`

Typical output:
- resolved worktree path
- editable vs read-only status
- no agent transcript

Important behavior:
- slug is optional; when omitted, a single existing matching worktree is resolved, multiple matches fail, and no match returns a placeholder path

### `/task-close`

Session:
- control-plane only

Purpose:
- remove a task worktree and prune git worktree state
- delete the task branch from the base repo when safe

Use it when:
- repo-local work is finished and the worktree should be cleaned up
- you want the standard cleanup path instead of ad hoc git commands

Backed by:
- `./.opencode/bin/cleanup-task`

Usage:
- `/task-close <repo> <eng-id> [slug]`

Typical output:
- removed worktree path
- branch deletion status
- no agent transcript

Important behavior:
- slug is optional only when exactly one worktree exists for the repo and ENG id
- branch deletion uses the actual worktree branch when the worktree still exists, so cleanup works for `feature`, `bug`, `hotfix`, and `release` branches without requiring the type

### `/task-cleanup`

Session:
- control-plane only

Purpose:
- bulk preview or remove task worktrees
- ask before force-removing dirty worktrees
- prune git worktree state and delete local branches when safe

Use it when:
- multiple task worktrees are stale and should be cleaned up together
- you want to narrow cleanup by repo or ENG id
- you want a preview before deleting anything

Backed by:
- `./.opencode/bin/cleanup-worktrees`

Usage:
- `/task-cleanup`
- `/task-cleanup --apply`
- `/task-cleanup --repo icarus --apply`
- `/task-cleanup --eng-id ENG-123 --apply`
- `/task-cleanup --apply --force-dirty`

Typical output:
- matching clean and dirty worktrees
- dirty file summaries
- removed worktree paths
- safe branch deletion status
- summary counts

Important behavior:
- default mode is preview only
- by default, only task worktrees named `ENG-<id>-<slug>` are included
- clean worktrees are removed only when `--apply` is passed
- dirty worktrees are skipped in non-interactive shells unless `--force-dirty` is passed
- dirty worktrees prompt for force cleanup in interactive shells
- when a non-interactive run skips dirty worktrees, ask the user before rerunning with `--force-dirty`
- local branches are deleted with safe `git branch -d`; unmerged branches are kept
- pass `--include-non-task` only when release or other non-task worktrees should be considered

### `/compare`

Session:
- control-plane only

Purpose:
- compare the SHA currently deployed in `ops` with a target app SHA
- list the commits between deployed and target state

Use it when:
- you are preparing a release
- you need to see what will ship to `staging` or `production`
- you want to compare against `origin/main` or an explicit SHA

Backed by:
- `./.opencode/bin/compare`

Usage:
- `/compare <service> <environment> [target-sha]`

Typical output:
- deployed SHA
- target SHA
- commit list between those revisions
- no agent transcript

### `/compare-curl`

Session:
- control-plane preferred, either session when the helper is installed

Purpose:
- run two curl commands and compare their response bodies
- pretty-print JSON responses after recursively sorting object keys and array items before comparison
- emit concise Markdown context that a migration-fix agent can use to align local with staging

Use it when:
- you are comparing two API responses
- you need stable JSON diffs that are not polluted by object key or array item order
- you need to hand an agent concrete local-vs-staging response differences before fixing missing behavior

Backed by:
- `./.opencode/bin/compare-curl`

Usage:
- `/compare-curl '<curl ...>' '<curl ...>'`
- `/compare-curl <raw pasted local curl> <raw pasted staging curl>`
- `/compare-curl --input-file tmp/compare-curl-input.txt`
- `/compare-curl --format text '<curl ...>' '<curl ...>'`
- `/compare-curl --context 5 --left-label old --right-label new '<curl ...>' '<curl ...>'`
- `/compare-curl --line-diff '<curl ...>' '<curl ...>'`

Typical output:
- Markdown objective that tells the agent to make local match staging
- response snapshot table with status, content type, response size, and timing for each curl
- JSON path-level agent fix context that explains what local is missing or changing
- optional fenced line-numbered normalized response diff when `--line-diff` is passed
- skipped-diff diagnostics instead of a body diff when either side fails or returns HTTP 4xx/5xx

### `/pr-comments`

Session:
- either session when the repo argument is explicit

Purpose:
- fetch the PR description, issue comments, review summaries, and code review comments from GitHub

Use it when:
- you are reviewing PR feedback
- you want the full discussion context before making follow-up changes

Backed by:
- `./.opencode/bin/pr-comments`

Usage:
- `/pr-comments <repo> <pr-number>`

Typical output:
- PR metadata
- compact actionable review summary by default
- full PR description, issue comments, and review comments only when requested

### `/pr-review`

Session:
- either session when the PR URL is explicit

Purpose:
- perform a qualified review of any GitHub pull request
- classify findings as critical, medium, or light
- post code review comments and the final review outcome for someone else's PR
- output findings only when the PR belongs to the current GitHub user

Use it when:
- you need to review your own PR without posting comments
- you need to review someone else's PR and leave a formal GitHub review
- you need consistent severity and approval/change-request behavior

Backed by:
- `./.opencode/bin/pr-review`

Usage:
- `/pr-review <pr-url>`

Typical output:
- review packet path under `tmp/`
- findings by severity
- submitted review outcome, unless the PR is yours

Important behavior:
- collects PR metadata, files, comments, reviews, and diff with `gh`
- formats review comment severity/title as bold Markdown
- includes a short suggested solution for actionable findings when available
- all security issues are critical
- critical or medium findings produce a change-request review
- only light findings, or no findings, produce an approval review
- own PRs never receive comments, approvals, or change requests from the command

### `/pr-create`

Session:
- repo worktree with no repo args
- any session with an explicit worktree path
- control plane with explicit `repo eng-id`, when exactly one matching worktree exists
- control plane with explicit `repo eng-id slug`

Purpose:
- push the current task branch
- create a GitHub pull request
- generate a mandatory task-prefixed PR title and description
- combine Linear task context and proposed code changes into a short non-empty PR summary
- return the existing PR URL when one already exists for the branch

Use it when:
- repo-local changes are committed
- you are ready to open a draft or ready-for-review PR

Backed by:
- `./.opencode/bin/pr-create`

Usage:
- `/pr-create [worktree-path] [draft|ready]`
- `/pr-create [repo eng-id] [draft|ready]`
- `/pr-create [repo eng-id slug] [draft|ready]`

Typical output:
- branch
- GitHub repository
- PR mode
- PR title
- PR URL

Important behavior:
- defaults to `draft`
- repo worktree sessions should run `./.opencode/bin/pr-create [draft|ready]` instead of locating the control-plane checkout
- requires a task id that can be inferred from args, branch, or worktree path
- generates the PR title as `ENG-<id>: <latest commit subject or task slug>`
- fetches Linear context before running when issue details are not already present in context
- passes Linear title, description, and acceptance criteria to the script when available
- generates the PR body with a short summary that mixes task context with proposed changes, changed files, validation checklist, and rollout notes
- runs root `lint` and `typecheck` package scripts when present before pushing the branch
- supports `PR_SKIP_VALIDATION=1` only for unusual repos without an applicable local validation path
- refuses dirty worktrees
- refuses to create a PR from `main`
- use `/release-prepare`, not `/pr-create`, for ops release tag updates

### `/session-brief`

Session:
- either session
- from a repo worktree, omit the path to summarize the current repo
- from the control plane, pass an explicit repo or worktree path

Purpose:
- produce a compact handoff summary for one repo or worktree
- avoid repeated broad discovery by repo-scoped agents

Use it when:
- a parent session is about to spawn explorers, implementers, or validators
- you need path, branch, dirty state, package scripts, and local instruction presence

Backed by:
- `./.opencode/bin/session-brief`

Usage:
- `/session-brief [repo-or-worktree-path]`

Typical output:
- path
- branch
- git status
- recent commits since `origin/main`
- changed files since `origin/main`
- package scripts
- likely validation commands
- runtime link and env-file status
- open PR URL when available
- local `AGENTS.md` presence

### `/workspace-status`

Session:
- control-plane only

Purpose:
- report workspace health without a broad agent investigation
- identify dirty control-plane files, submodule pointer drift, dirty worktrees, missing runtime links, and installed agent counts

Use it when:
- before starting or closing worktrees
- after submodule pointer drift appears in `git status`
- before committing control-plane changes

Backed by:
- `./.opencode/bin/workspace-doctor`

Usage:
- `/workspace-status`

Typical output:
- control-plane git status
- submodule clean/drift status
- repo worktree dirty state
- `node_modules` link status
- active control-plane agents

### `/knowledge-bootstrap`

Session:
- control-plane preferred
- either session when the shared helper is installed

Purpose:
- build the filtered first Graphify knowledge graph
- keep `odin` and product non-code files out of the v1 graph
- include control-plane docs and `knowledge/` notes as the narrative layer

Use it when:
- you need to dry-run the first Graphify corpus selection and cost estimate
- you are ready to run a smoke extraction before full bootstrap
- the merged local graph needs to be regenerated from the approved v1 sources

Backed by:
- `./.opencode/bin/knowledge-bootstrap`

Usage:
- `/knowledge-bootstrap`
- `/knowledge-bootstrap --smoke --extract`
- `/knowledge-bootstrap --smoke --extract --skip-control-docs`
- `/knowledge-bootstrap --merge-existing --no-cluster --skip-control-docs`
- `/knowledge-bootstrap --extract`

Typical output:
- included product repos and code file counts
- excluded repo list
- control-plane doc count and semantic cost estimate
- local staging and merged graph paths
- Graphify extraction or merge errors when extraction is requested

Important behavior:
- defaults to dry-run; pass `--extract` to run Graphify
- use `--merge-existing --no-cluster --skip-control-docs` to repair a raw merge after extraction already finished
- never runs raw `graphify extract .` from the control-plane root
- writes generated output under a local temp staging directory and ignored `graphify-out/`
- raw graph merges normalize temporary bootstrap corpus IDs before writing `graphify-out/merged-graph.json`
- the default OpenAI backend requires Graphify's tool environment to include `openai`; install with `uv tool install graphifyy --with openai --force`
- `--skip-control-docs` validates product code extraction without semantic docs or API calls
- use `--smoke --extract` before the full extraction

### `/knowledge`

Session:
- either session when the shared helper is installed

Purpose:
- ask a graph-first codebase question without spelling out the Graphify command
- make architecture, flow, dependency, impact, and "how A connects to B" questions cheaper to explore

Use it when:
- you want a quick map before targeted source reads
- you want to force graph-first behavior for a specific question
- a natural question is broad enough that raw repo search would be noisy

Backed by:
- `./.opencode/bin/knowledge-query`

Usage:
- `/knowledge how does shipper email signup work?`
- `/knowledge how is createEmailShipper connected to signup tracking?`
- `/knowledge what is affected by driver registration?`

Typical output:
- graph path used
- Graphify traversal output
- follow-up explanation from the agent with verified file paths when needed

Important behavior:
- queries `graphify-out/merged-graph.json` by default
- accepts `GRAPHIFY_GRAPH=/path/to/graph.json` for an override
- does not run extraction, update, bootstrap, hooks, or semantic API work
- Graphify output is a navigation index; important claims still need targeted source verification

### `/cross-impl`

Session:
- control-plane only

Purpose:
- split a product task into repo-scoped implementation work
- assign ownership boundaries and sequencing across repos

Use it when:
- a task touches multiple repos
- you need a small, explicit repo-by-repo execution plan

Backed by:
- prompt workflow only

Usage:
- `/cross-impl <eng-id> <goal>`

Typical output:
- repo-by-repo plan
- worktree targets
- dependency order

### `/migration-audit`

Session:
- control-plane only

Purpose:
- audit migration boundaries between `dinah` and target repos
- identify ownership, rollout, and cleanup risks

Use it when:
- you are evaluating Phase 1 or Phase 2 migration readiness
- you need to trace routes, flags, jobs, or data ownership across repos

Backed by:
- prompt workflow only

Usage:
- `/migration-audit <feature-area>`

Typical output:
- ownership map
- remaining legacy dependencies
- rollout and cutoff risks
- cleanup targets

### `/release-prepare`

Session:
- control-plane only

Purpose:
- coordinate release preparation for a service through the `ops` repo
- keep release work isolated from app implementation worktrees

Use it when:
- you are preparing a release branch in `ops`
- you need to update image tags from app repo heads
- you want a deterministic release workflow that commits, pushes, and opens the PR

Important behavior:
- the flow fails early if `repos/ops` is dirty

Backed by:
- `./.opencode/bin/release-prepare`

Usage:
- `/release-prepare <service> [environment]`

Typical output:
- release worktree path
- target SHA
- changed values files
- commit SHA
- PR URL

## Recommended Workflow

### Starting repo work

1. In the control-plane session, use `/task-start` to create repo worktrees.
2. In the control-plane session, use `/task-map` when you need to confirm the canonical worktree path.
3. Open OpenCode in the target worktree for implementation.

### Cross-repo task

1. In the control-plane session, use `/cross-impl` to split the work by repo.
2. In the control-plane session, create one worktree per editable repo with `/task-start`.
3. In repo worktree sessions, keep one editing owner per repo worktree.

### Migration task

1. In the control-plane session, use `/migration-audit` to map legacy and target ownership.
2. Treat `dinah` as read-only.
3. Push implementation into editable target repo worktree sessions only.

### Release task

1. In the control-plane session, use `/compare` to inspect deployed vs target SHA.
2. In the control-plane session, use `/release-prepare` to create the isolated `ops` release worktree, commit the release, push the branch, and open the PR.
3. Review the returned PR URL.

### Cleanup

1. In either session, use `/pr-comments` to gather review context if follow-up changes are needed.
2. In the repo worktree session, finish validation and make sure task state is durable.
3. In the control-plane session, use `/task-close` when one task worktree is ready to be removed.
4. Use `/task-cleanup` without `--apply` first when multiple stale task worktrees should be cleaned together.

## Command Wiring Status

Script-backed commands:
- `/compare` → `./.opencode/bin/compare`
- `/compare-curl` → `./.opencode/bin/compare-curl`
- `/knowledge-bootstrap` → `./.opencode/bin/knowledge-bootstrap`
- `/knowledge` → `./.opencode/bin/knowledge-query`
- `/pr-create` → `./.opencode/bin/pr-create`
- `/pr-comments` → `./.opencode/bin/pr-comments`
- `/pr-review` → `./.opencode/bin/pr-review`
- `/release-prepare` → `./.opencode/bin/release-prepare`
- `/session-brief` → `./.opencode/bin/session-brief`
- `/task-close` → `./.opencode/bin/cleanup-task`
- `/task-cleanup` → `./.opencode/bin/cleanup-worktrees`
- `/task-map` → `./.opencode/bin/worktree-map`
- `/task-start` → `./.opencode/bin/new-task`
- `/workspace-status` → `./.opencode/bin/workspace-doctor`

Prompt-only commands:
- `/cross-impl`
- `/migration-audit`

Related helpers not currently exposed as slash commands:
- `./.opencode/bin/new-release`
- `./.opencode/bin/release-pr-body`
- `./.opencode/bin/validate-control-plane`
- `./.opencode/bin/repo-profile`

## What Not To Do

- Do not use the control-plane repo as the main implementation session.
- Do not use an agent when a slash command only needs to run one deterministic script.
- Do not edit application code directly in `repos/*`.
- Do not perform release edits from app worktrees.
- Do not run `/release-prepare` while `repos/ops` has unrelated dirty state.
- Do not create editable worktrees for `dinah`.
