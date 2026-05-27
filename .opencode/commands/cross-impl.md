---
description: Coordinate a cross-repo implementation task.
---

Usage: `/cross-impl <eng-id> <goal>`

Delegate cross-repo planning to the `manager` agent when available.

Rules:
- Pass the full slash-command invocation unchanged.
- Break the goal into repo-scoped tasks.
- Use one editing owner per repo.
- Use explorers before implementers if boundaries are unclear.
- Return a short repo-by-repo plan with worktree targets, dependencies, and validation owners.
