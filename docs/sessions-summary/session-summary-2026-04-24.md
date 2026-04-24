# Session Summary: OpenCode Delegation And Context Optimization

This session reviewed and improved the control-plane OpenCode configuration with the goal of using subagents more effectively, reducing repetitive token consumption, and improving command speed.

## Main Changes

- Converted simple script-backed slash commands to fast paths instead of routing them through the manager:
  - `/compare`
  - `/task-start`
  - `/task-map`
  - `/task-close`
  - `/pr-comments`
- Kept agent delegation for work that benefits from planning or repo-scoped execution:
  - `/cross-impl`
  - `/migration-audit`
  - `/release-prepare`
- Expanded agent contracts with explicit output formats and delegation rules:
  - `manager`
  - `explorer`
  - `implementer`
  - `auditor`
  - `release`
- Added a new `validator` agent for validation-only work without edits.
- Added `/session-brief` and `bin/session-brief` to provide compact repo/worktree handoffs.

## OpenCode Profiles

The default `opencode.json` was made lean:
- remote MCP integrations disabled by default
- only shared and engineering instructions loaded

Additional profile configs were added:
- `opencode.migration.json`
- `opencode.release.json`
- `opencode.external.json`
- `opencode.full.json`

`bin/install-local-opencode` now accepts an optional profile:

```bash
./bin/install-local-opencode <repo-or-worktree-path> [engineering|migration|release|external|full]
```

## Documentation Updates

- `docs/commands.md` now separates:
  - control-plane-only commands
  - repo worktree session activity
  - commands safe in either session
- `docs/agents.md` documents the new validator role and parallel fan-out/fan-in workflow.
- `README.md` documents scoped profiles, session boundaries, and `session-brief`.
- `.opencode/tools/README.md` records the current script-backed helper approach.

## Path Hygiene

User-specific absolute paths were removed from shared docs and config.

Changes included:
- configs now reference instruction files and `worktrees` with relative paths
- README links now use relative doc links
- `lib/worktree-map.mjs` now returns repo-relative worktree paths
- `bin/session-brief` prints control-plane-relative paths when possible

## Validation

Completed checks:
- parsed all `opencode*.json` files successfully
- ran `bash -n` on updated shell scripts
- tested `bin/install-local-opencode` profile selection in a temporary git repo
- tested `bin/worktree-map`
- tested `bin/session-brief`
- verified no remaining user-specific local path prefixes outside excluded product repos/worktrees
