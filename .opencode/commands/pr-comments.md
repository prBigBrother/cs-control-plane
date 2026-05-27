---
description: Fetch PR description, comments, and review threads from GitHub.
---

Usage: `/pr-comments <repo> <pr-number>`

Run the script path for the current session:
- repo worktree: `./.opencode/bin/pr-comments <repo> <pr-number>`
- control plane: `./bin/pr-comments <repo> <pr-number>`

Rules:
- Do not delegate.
- Accept repo as `ops` or `citizenshipper/ops`.
- Summarize unresolved/actionable review context only unless full text is requested.
