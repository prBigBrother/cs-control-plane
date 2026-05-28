---
description: Resolve the worktree path for a repo task.
---

Usage: `/task-map <repo> <eng-id> [slug]`

Run `./.opencode/bin/worktree-map <repo> <eng-id> [slug]`.

Rules:
- Do not delegate.
- If slug is omitted, let the script resolve one existing match or return a placeholder path.
- Return path plus editable/read-only status only.
