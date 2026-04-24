Run a migration-oriented audit across legacy and target repos.

Delegation:
- Immediately use the `Task` tool to delegate to the `migration-auditor` agent.
- Pass the full slash-command invocation as the task prompt so the agent receives the original args unchanged.
- The migration auditor should use repo-scoped explorer subagents in parallel for independent target repos.
- Return only the consolidated audit, not raw explorer transcripts.

Usage:
`/migration-audit <feature-area>`

Rules:
- Include `dinah` as a read-only source.
- Include likely target repos such as `daedalus`, `icarus`, `ops`, and `olympus` when relevant.
- Focus on dependencies, flags, routes, data ownership, rollout points, and cleanup targets.
