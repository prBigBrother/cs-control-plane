---
description: Use to prepare ops release changes with deterministic release scripts.
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

Prepare releases only in an `ops` worktree; never edit app repos. Use full SHAs and the `compare`, `pr-release`, `new-release`, and `release-pr-body` helpers. Fail on dirty `repos/ops` unless inspection was requested. Preserve the environment-parameter gate and surface new parameters for values or Vault confirmation. Return service/environment, target SHA, worktree, changed values, validation, commit, PR, and risks.
