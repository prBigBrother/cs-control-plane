# OpenCode Diagnostic Permissions

Date: 2026-05-29

Decision:
- Allow common read-only diagnostic commands automatically for shared agents.
- Keep destructive git and package-manager commands behind approval.
- Tell agents to run simple diagnostics as separate commands or through `.opencode/bin` helpers instead of chaining with `&&`, `;`, or pipes.

Rationale:
- OpenCode command permission matching is pattern-based. Long chained commands can trigger prompts even when each individual command is safe.
- Broad permissions such as `git *` or `npm *` would also allow destructive operations like reset, checkout, push, install, or dependency mutation.
- Separate commands keep automatic permissions predictable and make output easier to review.

Allowed automatically:
- Read-only git diagnostics: `status`, `diff`, `log`, `show`, `branch`, `rev-parse`, `ls-files`, and `grep`.
- Runtime/package inspection where useful: package-manager version checks, `npm run`, `npm pkg get`, `npm ls`, `pnpm list`, and `yarn list`.
- Repo Implementer and Validator can run package scripts for validation and implementation workflows through `npm run *`, `pnpm run *`, `yarn run *`, `bun run *`, and common test shorthands.

Still requires approval:
- `git add`, `git commit`, `git push`, `git checkout`, `git reset`, `git clean`, `git pull`, `git merge`, and `git rebase`.
- `npm install`, `npm add`, dependency mutation, and broad package-manager access such as `npm *`, `pnpm *`, `yarn *`, or `bun *`.
