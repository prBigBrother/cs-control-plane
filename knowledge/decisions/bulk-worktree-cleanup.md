# Bulk Worktree Cleanup

## Decision

Bulk cleanup uses `/task-cleanup`, backed by `bin/cleanup-worktrees`.

The helper previews by default and only removes matching clean task worktrees when `--apply` is passed. Dirty worktrees are never removed silently:
- interactive runs ask before force-removing each dirty worktree
- non-interactive runs skip dirty worktrees unless `--force-dirty` is explicitly passed
- local branches are deleted with safe `git branch -d`; unmerged branches are kept

## Rationale

Bulk cleanup is useful after several task streams have merged, but stale worktrees can still contain local-only changes. Requiring preview mode and an explicit force decision protects unfinished work while keeping the common clean-worktree cleanup path fast.
