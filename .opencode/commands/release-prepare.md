Prepare a release in the `ops` repo based on app repo heads.

Usage:
`/release-prepare <service> [environment]`

Rules:
- Operate through the `ops` worktree only.
- Read the target service repo head SHA from its base checkout or target branch.
- Stage only release repo changes.
