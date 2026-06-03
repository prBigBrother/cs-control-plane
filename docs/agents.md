# Using Control-Plane Agents

This document explains the current shared agents in the control plane and when to use them.

## Core Rule

- Open OpenCode in the target repo worktree for implementation.
- Use the control plane only for shared orchestration, release helpers, and cross-repo coordination.
- One editable repo gets one owner at a time.
- When a prompt names an `ENG-<id>` task without issue details, resolve the Linear issue before repo investigation or implementation.
- Before implementation or validation, create or repair target worktrees with `/task-start`; use `/task-start --force-install` when validation reports missing modules or wrong platform binaries.
- Format URLs in agent output as Markdown links so they are clickable, except inside raw logs or code blocks.

## Agent List

OpenCode uses the lowercase file name as the agent id. In the UI, treat these as the human-facing roles:
- `manager` = Manager
- `explorer` = Explorer
- `implementer` = Implementer
- `validator` = Validator
- `auditor` = Auditor
- `release` = Release
- `linear-operator` = Linear Operator
- `datadog-investigator` = Datadog Investigator

The Manager is the primary coordinator. Other shared agents are subagents with scoped permissions and step limits.

Step budgets:
- Manager: 16
- Explorer: 12
- Implementer: 30
- Validator: 10

Agent files live in packs:
- `.opencode/agent-packs/control-plane/` contains Manager, Auditor, and Release.
- `.opencode/agent-packs/repo/` contains Explorer, Implementer, and Validator.
- `.opencode/agent-packs/common/` contains shared Linear and Datadog specialists.
- `.opencode/agents/` is the active OpenCode set.

Default agent behavior:
- control-plane profiles default to `manager`
- repo/worktree profiles default to `explorer`
- built-in `build` is disabled in shared profiles

Automatic command permissions:
- read-only git diagnostics are allowed, including `status`, `diff`, `log`, `show`, `branch`, `rev-parse`, `ls-files`, and `grep`
- common shell inspection helpers are allowed, including `grep *`, `rg *`, `echo *`, and `awk *`
- package-manager version and package inspection commands are allowed where useful
- `npm run lint` and `npm run typecheck` are allowed for shared agents
- repo Implementer and Validator have unrestricted bash so environment-prefixed commands, pipelines, package scripts, and repo validation commands run without repeated approvals
- Validator still has `edit: deny` and a behavioral no-mutation rule, but unrestricted bash can technically modify files
- `python3 *`, `gh *`, `tap-spec *`, `ts-node *`, `echo *`, and `awk *` are intentionally trusted commands by local policy; use them only for scoped project work
- destructive git/package commands still require approval in restricted roles; Implementer and Validator are intentional unrestricted-bash exceptions
- restricted roles should avoid `&&`, `;`, and pipes for simple diagnostics because separate commands preserve automatic permission matching

`bin/install-local-opencode` installs only the selected agent pack into repo/worktree sessions:
- `repo` shows common agents plus Explorer, Implementer, and Validator.
- `control-plane` shows common agents plus Manager, Auditor, and Release.
- `full` shows common agents plus all project agents.
- the control-plane root defaults to `full` so Manager can delegate discovery, implementation, and validation to repo-scoped agents while still requiring product edits to happen in worktrees.

### Manager

Purpose:
- coordinate work across multiple repositories
- break a product task into repo-scoped work
- keep cross-repo context small and explicit

Use it when:
- a task touches more than one repo
- you need to sequence frontend, backend, and ops work
- you need to decide which repo sessions should own which parts

Do not use it for:
- direct product-code edits
- deep repo-local investigation when only one repo is involved

Typical output:
- `Completion Gate:` with Linear, worktree readiness, Graphify, implementation, validation, diff review, blockers, and next action
- compact repo-by-repo status
- dependency order when relevant

Agent id:
- `manager`

### Explorer

Purpose:
- inspect one repo or one worktree in read-only mode
- map files, runtime surfaces, and risks quickly

Use it when:
- you need discovery before implementation
- you are unsure which module, route, flag, or job is involved
- you want a narrow repo summary without editing

Do not use it for:
- making changes
- cross-repo planning
- direct Linear or Datadog tool use; delegate those to the specialists

Typical output:
- Linear context used
- touched files
- important entry points
- risk list
- missing information to resolve before coding

Agent id:
- `explorer`

### Linear Operator

Purpose:
- look up, create, comment on, assign, or update Linear issues

Use it when:
- ENG task context is missing
- ticket metadata or comments are needed
- a Linear write is explicitly requested

Agent id:
- `linear-operator`

### Datadog Investigator

Purpose:
- investigate production or staging behavior using Datadog logs, traces, spans, metrics, incidents, or RUM

Use it when:
- a prompt mentions logs, traces, incidents, runtime behavior, failed jobs, request IDs, shipment/order/user IDs, or deploy regressions

Agent id:
- `datadog-investigator`

### Implementer

Purpose:
- make changes inside one editable repo worktree

Use it when:
- task scope is already clear for a single repo
- you want one session or one owner to handle that repo end to end

Rules:
- own exactly one repo worktree
- follow that repo's local `AGENTS.md`
- do not edit other repos from this role

Typical output:
- code changes in that repo only
- repo-local validation
- ready-to-review delta

Agent id:
- `implementer`

### Validator

Purpose:
- validate one repo or one worktree without making edits
- keep lint, typecheck, test, and smoke-check output outside the parent context

Use it when:
- implementation is complete and validation can run independently
- multiple repos need validation in parallel
- a parent session only needs pass/fail plus the first actionable failure

Do not use it for:
- editing files
- broad investigation before the implementation scope is known

Typical output:
- commands run
- pass/fail result
- first actionable failure
- suggested owner for follow-up

Agent id:
- `validator`

### Auditor

Purpose:
- analyze migration boundaries between `dinah` and target repos

Use it when:
- you are auditing Phase 1 or Phase 2 migration readiness
- you need to trace read paths, write paths, flags, jobs, and runtime ownership
- you need cutoff risks and cleanup candidates

Rules:
- treat `dinah` as read-only
- focus on data ownership, routes, flags, jobs, and remaining runtime dependency edges

Typical output:
- current ownership map
- remaining Dinah dependency list
- rollout/cutoff risks
- cleanup targets for Phase 2

Agent id:
- `auditor`

### Release

Purpose:
- prepare release changes in the `ops` repo only

Use it when:
- you are updating image tags in `ops`
- you need release-specific worktrees
- you need release PR bodies or deployed-vs-head comparisons

Rules:
- work only in an `ops` worktree
- use full commit SHAs
- keep release flow script-driven and deterministic

Typical output:
- isolated `ops` release worktree
- release PR body
- changed values files only

Agent id:
- `release`

## Recommended Workflow

### Single-repo task

1. Create the worktree with `./.opencode/bin/new-task`.
2. Open OpenCode in that worktree.
3. Use `explorer` if the scope is unclear.
4. Use `implementer` once the path is clear.

### Cross-repo task

1. Use `manager` to split the task by repo.
2. Create one worktree per editable repo.
3. Use one `explorer` per repo in parallel when boundaries are unclear.
4. Use one `implementer` per editable repo worktree once the edit scope is known.
5. Use one `validator` per changed repo when validation can run independently.
6. Bring compact summaries back together in the parent session.

### Migration task

1. Start with `migration-audit`.
2. Treat `dinah` as source and reference only.
3. Push implementation into `daedalus`, `icarus`, and `ops` worktrees as needed.

### Release task

1. Use `./.opencode/bin/compare` to inspect deployed vs target SHA.
2. Use `/pr-release` to create the `ops` release worktree, commit the release, push the branch, and open the PR. Pass comma-separated services without spaces when needed, for example `/pr-release daedalus,icarus production`.
3. Review the created PR.

## Commands That Fit The Agents

- `/task-start` pairs with `implementer`
- `/task-map` helps `manager` and `explorer`
- `/cross-impl` is the `manager` entry point
- `/migration-audit` pairs with `auditor`
- `/compare` and `/pr-release` pair with `release`
- `/pr-comments` is useful when reviewing or addressing PR feedback
- `/pr-review` performs a formal qualified PR review with severity-based approval or change request
- `/session-brief` gives repo-scoped agents compact state before handoff
- `/workspace-status` checks shared workspace health before or after orchestration
- `/task-close` is for cleanup after repo-local work is finished
- `/task-cleanup` is for previewing or bulk-cleaning stale task worktrees

## What Not To Do

- Do not use the control-plane session as the main coding session.
- Do not let two editing sessions work in the same repo worktree.
- Do not use `auditor` as a general code search tool for non-migration tasks.
- Do not perform release edits from app worktrees.
- Do not delegate deterministic script-backed commands just to run a script.
