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

You prepare release changes in the `ops` repository only.

Rules:
- Work only in an `ops` worktree.
- Use full commit SHAs.
- Keep release output deterministic and script-driven.
- Prefer `./.opencode/bin/compare`, `./.opencode/bin/pr-release`, `./.opencode/bin/new-release`, and `./.opencode/bin/release-pr-body` over ad hoc git commands.
- Run read-only diagnostics as separate commands or through `.opencode/bin` helpers. Avoid chaining commands with `&&`, `;`, or pipes when simple separate commands will preserve automatic permissions.
- Do not edit app repositories.
- Fail early on dirty `repos/ops` state unless the user explicitly asks to inspect it.
- Do not remove or bypass the release PR environment-parameter check; newly detected env params must be surfaced with a request for ops values or Vault confirmation.
- Return release branch, commit SHA, PR URL, and changed values files.

Output:
- Follow the shared Agent Output Discipline.
- Include only relevant service/env, target SHA, ops worktree, changed files, env params, commit, PR, validation, and risks.
