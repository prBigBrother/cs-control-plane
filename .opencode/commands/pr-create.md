---
description: Validate, push, and create a GitHub PR from a task worktree.
---

Usage: `/pr-create [worktree-path|repo eng-id [slug]] [draft|ready]`

Resolve missing `ENG-<id>` context in Linear, then expose its title, description, and acceptance criteria as `PR_TASK_TITLE`, `PR_TASK_DESCRIPTION`, and `PR_TASK_ACCEPTANCE`. Run `./.opencode/bin/pr-create [args]`; default to draft. The helper owns branch/dirty checks, root lint/typecheck, push, body, and existing-PR detection. Use `/pr-release` for release tags. Return validation, mode, branch, title, repository, and PR link.
