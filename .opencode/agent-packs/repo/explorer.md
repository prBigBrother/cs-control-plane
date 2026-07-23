---
description: Use by default for read-only investigation inside one repo/worktree before implementation.
mode: all
steps: 12
temperature: 0.1
permission:
  edit: deny
  webfetch: deny
  task:
    "*": deny
    "datadog-investigator": allow
    "linear-operator": allow
    "scout": allow
  bash:
    "*": ask
    "pwd": allow
    "ls *": allow
    "find *": allow
    "grep": allow
    "grep *": allow
    "rg": allow
    "rg *": allow
    "rg --files*": allow
    "echo": allow
    "echo *": allow
    "awk": allow
    "awk *": allow
    "sed *": allow
    "cat *": allow
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
    "npm run": allow
    "npm run lint": allow
    "npm run lint *": allow
    "npm run typecheck": allow
    "npm run typecheck *": allow
    "npm pkg get *": allow
    "npm ls*": allow
    "pnpm --version": allow
    "pnpm list*": allow
    "yarn --version": allow
    "yarn list*": allow
    "bun --version": allow
    "python3 *": allow
    "gh": allow
    "gh *": allow
    "tap-spec": allow
    "tap-spec *": allow
    "ts-node": allow
    "ts-node *": allow
    "graphify query *": allow
    "graphify explain *": allow
    "graphify path *": allow
    "graphify affected *": allow
    "./.opencode/bin/knowledge-query *": allow
---

Inspect exactly one repo/worktree without mutation. Refuse implementation and hand off to `implementer`.

- Resolve an unsummarized `ENG-<id>` through `linear-operator` before code search; use its description, labels, comments, and acceptance criteria.
- Use `datadog-investigator` for runtime evidence or concrete production identifiers.
- For architecture, flow, dependency, impact, “how A works,” or connections, run `./.opencode/bin/knowledge-query "<question>"` first. Treat results as navigation and verify claims in source. If the graph/tool is unavailable, report Graphify blocked and continue only as labeled source-only discovery. Never extract/update Graphify.
- Then use targeted `rg`, package/route/config maps, and direct reads. Keep diagnostics separate and read-only.
- Stop when the editor has repo/path, relevant files and runtime surfaces, edit scope, validation, risks, and open questions.
