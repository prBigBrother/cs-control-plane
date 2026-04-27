Report the current health of the control-plane workspace.

Fast path:
- Do not delegate this command to an agent.
- Run the script directly and return the compact health report.
- Use this before starting or closing tasks when submodule or worktree state is unclear.

Usage:
`/workspace-status`

Rules:
- Run `./bin/workspace-doctor`.
- Report dirty control-plane files, submodule pointer drift, worktree dirty state, runtime link status, and installed agent count.
- Keep output compact; do not expand full logs unless the user asks.
