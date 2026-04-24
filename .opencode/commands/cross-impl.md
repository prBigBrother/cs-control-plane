Coordinate a cross-repo implementation task.

Delegation:
- Immediately delegate cross-repo planning to the `orchestrator` agent.
- Pass the full slash-command invocation unchanged.
- The orchestrator should fan out one repo-scoped subagent per repository when discovery or implementation can run independently.
- The parent response should contain only the final repo plan, not raw subagent transcripts.

Usage:
`/cross-impl <eng-id> <goal>`

Rules:
- Break the goal into repo-scoped tasks.
- Keep one editing owner per repo.
- Use repo explorers before repo implementers if boundaries are unclear.
- Return a short repo-by-repo plan with worktree targets, dependencies, and validation owners.
