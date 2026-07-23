---
description: Coordinate a cross-repo implementation task.
---

Usage: `/cross-impl <eng-id> <goal>`

Delegate cross-repo planning to the `manager` agent when available.

Rules:
- Pass the full slash-command invocation unchanged.
- Separate read-only discovery dependencies from editable repo-scoped tasks.
- Use one editing owner per repo.
- Use explorers before implementers if boundaries are unclear.
- Retain and reuse one Validator task ID per repo after corrections.
- Return a short repo-by-repo plan with discovery sources, worktree targets, dependencies, and validation owners.
