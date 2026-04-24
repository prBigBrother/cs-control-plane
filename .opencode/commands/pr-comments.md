Fetch PR description, comments, and review threads from GitHub.

Fast path:
- Do not delegate this command to an agent.
- Run the script directly, then summarize only unresolved/actionable review context if the output is long.
- Keep raw comment bodies out of the parent context unless the user asks for full text.

Usage:
`/pr-comments <repo> <pr-number>`

Rules:
- Accept repo as `ops` or `citizenshipper/ops`.
- Run `./bin/pr-comments <repo> <pr-number>`.
- Prefer a compact summary with links, authors, and required actions.
