# Development Cycle

This guide describes the standard engineering cycle from task intake through release preparation. It assumes this control plane owns orchestration, while product code changes happen only inside repo worktrees.

## Core Rule

- Use the control-plane session for setup, cross-repo planning, migration audits, cleanup, release preparation, and shared command execution.
- Use repo worktree sessions for investigation, implementation, validation, commits, PR creation, and PR feedback fixes.
- Use one editing owner per repo worktree.
- Use subagents when work can run independently by repo or phase.
- Use script-backed commands directly when the task is deterministic.
- Control-plane sessions show Manager, Auditor, and Release.
- Repo worktree sessions show Explorer, Implementer, and Validator.

## 1. Intake And Scope

Session:
- control plane

Use:
- `manager` for cross-repo tasks
- `auditor` for migration or legacy cutoff tasks
- no agent for simple single-repo tasks with obvious scope

Commands:
- `/cross-impl <eng-id> <goal>` for multi-repo planning
- `/migration-audit <feature-area>` for Dinah-to-target migration analysis
- `/task-map <repo> <eng-id> [slug]` when you need to confirm a canonical worktree path

Output:
- repos involved
- worktree targets
- dependency order
- owner per repo
- validation expectations

Rules:
- Decide repo boundaries before editing.
- Do not investigate product code directly from `repos/*` for implementation.
- Do not create an editable `dinah` worktree.

## 2. Worktree Setup

Session:
- control plane

Use:
- no agent

Commands:
- `/task-start <repo...> <eng-id> [slug] [type]`

Equivalent script:

```bash
./bin/new-task <repo> <eng-id> [slug] [type]
```

Output:
- one worktree per editable repo under `worktrees/<repo>/ENG-<id>-<slug>/`
- shared OpenCode config installed
- repo agent pack installed for Tab switching
- repo-local `AGENTS.md` copied when present

Rules:
- Create worktrees from base checkouts under `repos/*`.
- Keep base submodule checkouts aligned to `main`.
- Open a separate OpenCode session in each repo worktree that will be edited.

## 3. Investigation

Session:
- repo worktree

Use:
- `explorer` when the edit scope is unclear
- one `explorer` per repo in parallel for independent repo investigations
- `/session-brief` before handoff when a compact state summary helps

Commands:
- `/session-brief`
- repo-local search and read-only inspection commands

Output:
- relevant files
- runtime surfaces
- suggested edit scope
- validation commands
- risks and open questions

Rules:
- Keep exploration read-only.
- Prefer targeted `rg` searches and local repo docs.
- Return summaries and paths, not large copied code blocks.

## 4. Development

Session:
- repo worktree

Use:
- `implementer` once scope is clear
- one implementer per editable repo worktree

Commands:
- repo-local build/dev commands from the repo's `AGENTS.md`
- repo-local package scripts as needed

Output:
- changed files
- validation run or pending validation
- residual risks
- handoff notes for parent orchestration

Rules:
- Edit only inside the assigned repo worktree.
- Do not let multiple agents edit the same worktree.
- Do not edit product code in `repos/*`.
- Keep changes scoped to the task and repo ownership boundary.

## 5. Validation

Session:
- repo worktree

Use:
- `validator` for validation-only work
- one validator per changed repo when validation can run in parallel

Commands:
- repo-local lint, typecheck, test, and smoke commands from that repo's `AGENTS.md`
- `/session-brief` if a parent session needs compact validation context

Output:
- commands run
- pass/fail status
- first actionable failure
- suggested owner for fixes

Rules:
- Match validation depth to changed surface.
- Keep full logs out of the parent context unless they explain a failure.
- If validation fails, send the failure back to the implementer for fixes.

## 6. Commit

Session:
- repo worktree

Use:
- no agent for straightforward commits
- `implementer` if final cleanup or validation fixes are still needed

Commands:
- repo-local `git status`
- repo-local `git diff`
- repo-local `git add`
- repo-local `git commit`

Output:
- commit SHA
- concise summary of changed files and validation

Rules:
- Commit only the relevant repo worktree changes.
- Do not include unrelated local files.
- Make sure validation status is known before committing.

## 7. Pull Request Creation

Session:
- repo worktree

Use:
- no agent for straightforward PR creation
- `manager` only when multiple repo PRs need sequencing or dependency notes

Commands:
- `/pr-create [draft|ready]` from the repo worktree
- `/pr-create <worktree-path> [draft|ready]` from any session
- `/pr-create <repo> <eng-id> [draft|ready]` from the control plane when one matching worktree exists
- `/pr-create <repo> <eng-id> <slug> [draft|ready]` from the control plane

Generated PR content includes:
- mandatory title prefix: `ENG-<id>:`
- summary from commits since `origin/main`
- changed files since `origin/main`
- validation checklist
- rollout notes placeholder

Rules:
- Create one PR per repo worktree.
- Make cross-repo dependencies explicit in each PR.
- For migration tasks, include Phase 1 or Phase 2 status and flags.
- Update the generated validation checklist before marking a draft PR ready for review.
- Use `/release-prepare`, not `/pr-create`, for ops release tag updates.

## 8. Code Review

Session:
- either session for reading comments
- repo worktree for fixes

Use:
- `/pr-comments <repo> <pr-number>` to gather review context
- `explorer` if a comment requires investigation
- `implementer` for code fixes
- `validator` after fixes

Commands:
- `/pr-comments <repo> <pr-number>`
- repo-local validation commands
- repo-local commit/push commands

Output:
- actionable review items
- fixes committed and pushed
- validation status after fixes

Rules:
- Fix comments in the same repo worktree that owns the PR.
- Keep review-fix commits scoped.
- Re-run validation that covers the changed surface.
- Do not resolve or dismiss review feedback without understanding it.

## 9. Merge

Session:
- repo worktree or GitHub UI/workflow

Use:
- no agent unless merge readiness needs cross-repo coordination
- `manager` when multiple PRs must merge in a specific order

Pre-merge checklist:
- required checks pass
- review approvals are complete
- dependent PRs are merged or ordered correctly
- migration flags and rollout notes are documented

Rules:
- Merge app PRs before preparing the `ops` release.
- For cross-repo work, merge according to the dependency order from the manager.
- Do not prepare a release from an unmerged feature branch unless explicitly requested.

## 10. Release Preparation For Ops

Session:
- control plane

Use:
- `release`

Commands:
- `/compare <service> <environment> [target-sha]`
- `/release-prepare <service> [environment]`

Equivalent scripts:

```bash
./bin/compare <service> <environment> [target-sha]
./bin/release-prepare <service> [environment]
```

Output:
- deployed SHA
- target app SHA
- commits included in release
- isolated `ops` release worktree
- changed values files
- release commit
- release PR URL

Rules:
- Release edits happen only in an `ops` worktree.
- Use full commit SHAs as image tags.
- Keep release flow script-driven.
- `repos/ops` must not have unrelated dirty state before release preparation.

## 11. Release PR Review And Follow-up

Session:
- control plane for release context
- `ops` worktree for release fixes

Use:
- `/pr-comments ops <pr-number>` for review feedback
- `release` for release-specific fixes
- `validator` only if validation is needed inside the `ops` worktree

Rules:
- Keep release PRs limited to values/tag updates and required release metadata.
- Do not mix app implementation changes into an ops release PR.
- If app code needs a fix, return to the app repo worktree cycle and prepare a new release after merge.

## 12. Cleanup

Session:
- control plane

Use:
- no agent

Commands:
- `/task-close <repo> <eng-id> [slug]`

Rules:
- Close worktrees only after PRs are merged or the branch is no longer needed.
- Persist any durable notes before cleanup.
- Keep `repos/*` base checkouts clean.

## Quick Flow

1. Control plane: `/cross-impl` or decide single repo.
2. Control plane: `/task-start`.
3. Repo worktree: `/session-brief`, then `explorer` if needed.
4. Repo worktree: `implementer`.
5. Repo worktree: `validator`.
6. Repo worktree: commit, then `/pr-create`.
7. Either session: `/pr-comments`.
8. Repo worktree: fix review comments, validate, push.
9. GitHub/repo workflow: merge.
10. Control plane: `/compare`.
11. Control plane: `/release-prepare`.
12. Control plane: `/task-close`.
