---
description: Create a GitHub pull request for a repo worktree branch.
---

Usage:
- `/pr-create [worktree-path] [draft|ready]`
- `/pr-create [repo eng-id] [draft|ready]`
- `/pr-create [repo eng-id slug] [draft|ready]`

Run `./.opencode/bin/pr-create [args...]`.

Before running:
- If an `ENG-<id>` is known and Linear context is absent, fetch it.
- Pass available Linear context as `PR_TASK_TITLE`, `PR_TASK_DESCRIPTION`, and `PR_TASK_ACCEPTANCE`.

Rules:
- Default to draft unless `ready` is explicit.
- Let the script enforce branch, dirty-state, validation, push, title/body, and existing-PR checks.
- Use `/pr-release`, not `/pr-create`, for ops release tag updates.
- Return branch, repository, mode, title, PR URL, and validation result only.
