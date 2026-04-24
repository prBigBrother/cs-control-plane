Prepare a release in the `ops` repo based on app repo heads.

Delegation:
- Delegate to the `release-manager` agent only after confirming the request needs release preparation rather than a simple compare.
- Pass the full slash-command invocation unchanged.
- The release manager must keep the flow script-driven and return the release branch, commit, and PR URL.

Usage:
`/release-prepare <service> [environment]`

Rules:
- Operate through the `ops` worktree only.
- Run `./bin/release-prepare <service> [environment]`.
- Fail if `repos/ops` is dirty before the release worktree is created.
- Return the script output directly.
