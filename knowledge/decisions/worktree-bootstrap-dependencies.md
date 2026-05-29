# Worktree Bootstrap Dependency Prep

## Decision

Task worktrees are created from the latest fetched `origin/main`, but the base checkout under `repos/*` is not pulled, checked out, or reset during task creation.

`new-task` prepares dependencies inside the worktree:
- use real worktree `node_modules` for lockfile repos
- run `npm ci` inside the worktree when lockfile dependencies are missing, linked from the base checkout, or explicitly forced
- link base `node_modules` only when installation is skipped or no lockfile is available
- skip dependency installation only when `--no-install` is explicitly passed
- force a fresh install with `--force-install`
- run `npm run db:generate` for Daedalus after dependency prep when Prisma is available

## Rationale

Creating from `origin/main` keeps new task branches current without mutating submodule checkouts in `repos/*`. Real worktree installs avoid stale or architecture-specific base `node_modules` issues, such as missing newly declared packages or missing platform binaries.

## Follow-Up

If dependency setup becomes too slow, add an explicit fast-path flag for trusted linked dependencies rather than making symlink reuse the default.
