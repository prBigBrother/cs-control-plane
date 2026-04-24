# Using Control-Plane Commands

This document explains the current shared slash commands in the control plane, when to use them, and which ones are backed by `bin/` scripts.

## Core Rule

- Use control-plane commands for shared orchestration, worktree bootstrap, release helpers, and review utilities.
- Prefer running implementation work inside the target repo worktree, not from the control-plane repo.
- When a command maps to a `bin/` script, prefer the script-backed path so behavior stays deterministic.

## Command List

### `/task-start`

Purpose:
- create one or more repo worktrees for an engineering task
- apply the standard branch and worktree naming rules
- install shared OpenCode config into each new worktree

Use it when:
- you are starting work in one or more editable repos
- you want the standard `worktrees/<repo>/ENG-<id>-<slug>` layout
- you want repo-local `AGENTS.md` copied into the worktree when present

Backed by:
- `./bin/new-task`

Usage:
- `/task-start <repo...> <eng-id> <slug> [type]`

Typical output:
- created worktree paths
- read-only skip notice for non-editable repos such as `dinah`

### `/task-map`

Purpose:
- resolve the expected worktree path for a repo task
- show whether the repo is editable in this control plane

Use it when:
- you need to confirm the canonical path for a task worktree
- you are coordinating work across sessions and need a stable target path

Backed by:
- `./bin/worktree-map`

Usage:
- `/task-map <repo> <eng-id> <slug>`

Typical output:
- resolved worktree path
- editable vs read-only status

### `/task-close`

Purpose:
- remove a task worktree and prune git worktree state
- delete the task branch from the base repo when safe

Use it when:
- repo-local work is finished and the worktree should be cleaned up
- you want the standard cleanup path instead of ad hoc git commands

Backed by:
- `./bin/cleanup-task`

Usage:
- `/task-close <repo> <eng-id> <slug>`

Typical output:
- removed worktree path
- branch deletion status

### `/compare`

Purpose:
- compare the SHA currently deployed in `ops` with a target app SHA
- list the commits between deployed and target state

Use it when:
- you are preparing a release
- you need to see what will ship to `staging` or `production`
- you want to compare against `origin/main` or an explicit SHA

Backed by:
- `./bin/compare`

Usage:
- `/compare <service> <environment> [target-sha]`

Typical output:
- deployed SHA
- target SHA
- commit list between those revisions

### `/pr-comments`

Purpose:
- fetch the PR description, issue comments, review summaries, and code review comments from GitHub

Use it when:
- you are reviewing PR feedback
- you want the full discussion context before making follow-up changes

Backed by:
- `./bin/pr-comments`

Usage:
- `/pr-comments <repo> <pr-number>`

Typical output:
- PR metadata
- PR description
- issue comments
- review comments and threads

### `/cross-impl`

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
- `./bin/release-prepare`

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

1. Use `/task-start` to create repo worktrees.
2. Use `/task-map` when you need to confirm the canonical worktree path.
3. Open OpenCode in the target worktree for implementation.

### Cross-repo task

1. Use `/cross-impl` to split the work by repo.
2. Create one worktree per editable repo with `/task-start`.
3. Keep one editing owner per repo worktree.

### Migration task

1. Use `/migration-audit` to map legacy and target ownership.
2. Treat `dinah` as read-only.
3. Push implementation into editable target repo worktrees only.

### Release task

1. Use `/compare` to inspect deployed vs target SHA.
2. Use `/release-prepare` to create the isolated `ops` release worktree, commit the release, push the branch, and open the PR.
3. Review the returned PR URL.

### Cleanup

1. Use `/pr-comments` to gather review context if follow-up changes are needed.
2. Use `/task-close` when the task worktree is ready to be removed.

## Command Wiring Status

Script-backed commands:
- `/compare` → `./bin/compare`
- `/pr-comments` → `./bin/pr-comments`
- `/release-prepare` → `./bin/release-prepare`
- `/task-close` → `./bin/cleanup-task`
- `/task-map` → `./bin/worktree-map`
- `/task-start` → `./bin/new-task`

Prompt-only commands:
- `/cross-impl`
- `/migration-audit`

Related helpers not currently exposed as slash commands:
- `./bin/new-release`
- `./bin/release-pr-body`
- `./bin/repo-profile`

## What Not To Do

- Do not use the control-plane repo as the main implementation session.
- Do not edit application code directly in `repos/*`.
- Do not perform release edits from app worktrees.
- Do not run `/release-prepare` while `repos/ops` has unrelated dirty state.
- Do not create editable worktrees for `dinah`.
