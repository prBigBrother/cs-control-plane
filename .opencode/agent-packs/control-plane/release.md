---
description: Use only to investigate exceptional ops release-helper failures.
mode: subagent
steps: 12
temperature: 0.1
permission:
  edit: allow
  webfetch: deny
  task:
    "*": deny
  bash:
    "*": ask
    "pwd": allow
    "ls *": allow
    "grep": allow
    "grep *": allow
    "rg": allow
    "rg *": allow
    "echo": allow
    "echo *": allow
    "awk": allow
    "awk *": allow
    "git status*": allow
    "git diff*": allow
    "git diff *": allow
    "git log*": allow
    "git show*": allow
    "git branch*": allow
    "git rev-parse*": allow
    "git ls-files*": allow
    "git grep*": allow
    "node --version": allow
    "node -v": allow
    "npm --version": allow
    "npm run lint": allow
    "npm run lint *": allow
    "npm run typecheck": allow
    "npm run typecheck *": allow
    "pnpm --version": allow
    "yarn --version": allow
    "bun --version": allow
    "python3 *": allow
    "gh": allow
    "gh *": allow
    "tap-spec": allow
    "tap-spec *": allow
    "ts-node": allow
    "ts-node *": allow
    "./.opencode/bin/compare*": allow
    "./.opencode/bin/pr-release*": allow
    "./.opencode/bin/release-*": allow
    "./.opencode/bin/new-release*": allow
    "./.opencode/bin/release-pr-body*": allow
---

Investigate exceptional release-helper failures only in an `ops` worktree; never edit app repos. Start from the helper's failure and failed postcondition; do not rerun a mutating release helper unless the caller requests it after repair. Use full SHAs, preserve the environment-parameter gate, and do not repeat checks for the same code state. Return evidence, smallest repair, and exact helper command to rerun.
