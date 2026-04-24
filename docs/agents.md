# Using Control-Plane Agents

This document explains the current shared agents in the control plane and when to use them.

## Core Rule

- Open OpenCode in the target repo worktree for implementation.
- Use the control plane only for shared orchestration, release helpers, and cross-repo coordination.
- One editable repo gets one owner at a time.

## Agent List

### `orchestrator`

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
- repo-by-repo work split
- worktree targets
- ownership boundaries
- dependency order

### `repo-explorer`

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

Typical output:
- touched files
- important entry points
- risk list
- missing information to resolve before coding

### `repo-implementer`

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

### `repo-validator`

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

### `migration-auditor`

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

### `release-manager`

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

## Recommended Workflow

### Single-repo task

1. Create the worktree with `./bin/new-task`.
2. Open OpenCode in that worktree.
3. Use `repo-explorer` if the scope is unclear.
4. Use `repo-implementer` once the path is clear.

### Cross-repo task

1. Use `orchestrator` to split the task by repo.
2. Create one worktree per editable repo.
3. Use one `repo-explorer` per repo in parallel when boundaries are unclear.
4. Use one `repo-implementer` per editable repo worktree once the edit scope is known.
5. Use one `repo-validator` per changed repo when validation can run independently.
6. Bring compact summaries back together in the parent session.

### Migration task

1. Start with `migration-audit`.
2. Treat `dinah` as source and reference only.
3. Push implementation into `daedalus`, `icarus`, and `ops` worktrees as needed.

### Release task

1. Use `./bin/compare` to inspect deployed vs target SHA.
2. Use `/release-prepare` to create the `ops` release worktree, commit the release, push the branch, and open the PR.
3. Use `release-manager` behavior in that `ops` session only.
4. Review the created PR.

## Commands That Fit The Agents

- `/task-start` pairs with `repo-implementer`
- `/task-map` helps `orchestrator` and `repo-explorer`
- `/cross-impl` is the `orchestrator` entry point
- `/migration-audit` pairs with `migration-auditor`
- `/compare` and `/release-prepare` pair with `release-manager`
- `/pr-comments` is useful when reviewing or addressing PR feedback
- `/session-brief` gives repo-scoped agents compact state before handoff
- `/task-close` is for cleanup after repo-local work is finished

## What Not To Do

- Do not use the control-plane session as the main coding session.
- Do not let two editing sessions work in the same repo worktree.
- Do not use `migration-auditor` as a general code search tool for non-migration tasks.
- Do not perform release edits from app worktrees.
- Do not delegate deterministic script-backed commands just to run a script.
