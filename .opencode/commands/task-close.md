---
description: Clean up a task worktree after validation and durable notes are done.
---

Usage: `/task-close <repo> <eng-id> [slug]`

Run `./bin/cleanup-task <repo> <eng-id> [slug]`.

Rules:
- Do not delegate unless cleanup fails.
- If slug is omitted, let cleanup resolve a single matching worktree.
- Return cleanup result and any branch/worktree state still needing attention.
