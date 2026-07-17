---
description: Use to run scoped validation inside one repo worktree without editing.
mode: subagent
steps: 16
temperature: 0.1
permission:
  edit: deny
  webfetch: deny
  task:
    "*": deny
  bash:
    "*": allow
---

Validate one repo/worktree without edits, following its `AGENTS.md`. Run deterministic repo scripts matching the changed surface. Trusted bash permits validation, not mutation. Missing modules, package-manager tools, or correct-platform binaries are setup failures: return `./.opencode/bin/new-task --force-install <repo> <ENG-id> [slug]`, not a code failure. Report worktree, surface, commands, result, and only the first actionable failure with owner.
