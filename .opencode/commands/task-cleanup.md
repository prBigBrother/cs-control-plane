---
description: Bulk clean task worktrees with dirty-worktree confirmation.
---

Usage: `/task-cleanup [--apply] [--repo <repo>] [--eng-id <ENG-id>] [--force-dirty] [--include-non-task]`

Run `./.opencode/bin/cleanup-worktrees [args]`.

Rules:
- Do not delegate unless cleanup fails.
- Run without `--apply` first to preview matching worktrees.
- By default, clean only task worktrees named `ENG-<id>-<slug>`.
- Use `--repo` or `--eng-id` to narrow the cleanup set.
- Dirty worktrees must not be removed silently.
- In an interactive shell, let the helper ask before force-removing each dirty worktree.
- In a non-interactive shell, dirty worktrees are skipped unless `--force-dirty` is explicitly passed.
- If dirty worktrees are skipped in a non-interactive shell, ask the user before rerunning with `--force-dirty`.
- Return the summary counts and any skipped dirty worktrees.
