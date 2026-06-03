# PR Release Command

Date: 2026-06-01

Decision:
- Rename `/release-prepare` to `/pr-release`.
- Rename the backing helper from `bin/release-prepare` to `bin/pr-release`.
- Accept one service or a comma-separated service list without spaces, for example `/pr-release daedalus,icarus production`.
- Create one isolated ops worktree, branch, commit, and pull request per service.

Rationale:
- The command creates release PRs, so `/pr-release` describes its outcome more directly.
- A comma-separated list avoids repeating the command when a deployment includes multiple services.
- Separate PRs preserve the existing service-scoped ops branches and make release review explicit.

Safety:
- Validate the complete service list and environment before performing remote git or GitHub operations.
- Reject empty, malformed, unsupported, whitespace-containing, or duplicate service entries.
- Continue to fail early when `repos/ops` has unrelated dirty state.
