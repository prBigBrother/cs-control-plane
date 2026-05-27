---
description: Return compact repo/worktree context for agent handoff.
---

Usage: `/session-brief [repo-or-worktree-path]`

Run the script path for the current session:
- repo worktree: `./.opencode/bin/session-brief [repo-or-worktree-path]`
- control plane: `./bin/session-brief [repo-or-worktree-path]`

Return path, branch, git status, package scripts, validation commands, runtime links, env files, open PR, and local AGENTS presence.
