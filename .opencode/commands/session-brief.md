---
description: Return compact repo/worktree context for agent handoff.
---

Usage: `/session-brief [path] [--json|--full]`

Run `./.opencode/bin/session-brief [path] [flags]`. Default output is the compact handoff; use `--json` for subagent context and `--full` only when detailed status, scripts, commits, or env-file metadata is needed. Return the helper output directly.
