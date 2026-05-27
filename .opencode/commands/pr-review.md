---
description: Run a qualified GitHub pull request review from a PR URL.
---

Usage: `/pr-review <pr-url>`

Run the script path for the current session:
- repo worktree: `./.opencode/bin/pr-review collect <pr-url>`
- control plane: `./bin/pr-review collect <pr-url>`

Review flow:
- Read generated `packet.md` and `diff.patch`; inspect code before deciding findings.
- Use severities: `critical` for security/data-loss/auth/crash/deploy breakage, `medium` for correctness/risky migration/test gaps, `light` for non-blocking cleanup.
- Write findings to generated `findings.json` with fields: `severity`, `path`, `line`, `title`, `body`, `suggestion`, `security`.
- If viewer is PR author, output findings only.
- Otherwise run the generated `submit` command; `critical`/`medium` findings request changes, only `light` or none approves.
- Return only review result, findings count, and PR URL.
