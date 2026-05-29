# Agent Worktree Readiness

## Decision

Manager must ensure target worktrees are created or repaired with `/task-start` before assigning implementation or validation.

If validation fails because of missing modules, missing package-manager binaries, or wrong platform binaries, agents must treat that as a setup failure. The repair path is `/task-start --force-install <repo> <ENG-id> [slug]`, followed by the same validation command.

If a subagent reaches its step limit before validation or final diff review, Manager must continue with another scoped subagent or a direct script-backed validation step instead of treating the task as complete.

Manager, Explorer, Implementer, and Validator get larger step budgets than the earlier ENG-253 run used: 16, 12, 30, and 10 steps respectively.

Manager final output must start with `Completion Gate:` and explicitly mark Linear context, worktree readiness, Graphify usage, implementation, validation, diff review, blockers, and next action.

## Rationale

Linked or stale `node_modules` can make valid code changes look broken. The process should repair the local environment first, then evaluate the product change. Step-limit handoffs are incomplete work, not successful completion.
