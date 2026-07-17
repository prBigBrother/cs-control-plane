---
description: Preview or clean task worktrees with dirty-state safeguards.
---

Usage: `/task-cleanup [--apply] [--repo <repo>] [--eng-id <ENG-id>] [--force-dirty] [--include-non-task]`

Run `./.opencode/bin/cleanup-worktrees [args]`. Always preview before `--apply`. Narrow by repo/task when supplied; include non-task worktrees only when explicit. Never force dirty cleanup silently: in noninteractive runs, show skipped dirty worktrees and obtain approval before `--force-dirty`. Return summary counts and skipped paths.
