---
description: Quick PR review — single-pass, repo-aware, critical/medium only. Use for a fast sanity check before merge. For a deep multi-agent review, use `/pr-review-deep`.
---

Usage: `/pr-review <pr-url>`

## Step 1: Verify prerequisites

Confirm `gh` is installed and authenticated:

```bash
gh auth status
```

If `gh` is not installed, stop and tell the user to install it from https://cli.github.com/.

## Step 2: Collect

Run `./.opencode/bin/pr-review collect --trim <pr-url>`.

Read the generated `packet.md` and `diff.patch`.

## Step 3: Detect repo and load rules

Extract the repo slug from the PR URL (e.g. `citizenshipper/daedalus` → `daedalus`).

Load the repo's rules file if it exists:
- `repos/<repo>/.agents.md` (daedalus, ops, olympus, odin)
- `repos/<repo>/.claude/claude.md` (odin fallback)
- `repos/<repo>/AGENTS.md` (any repo)

If no rules file is found, proceed with general TypeScript/Node review heuristics.

## Step 4: Quick review

Review only for **blocking** issues. Skip style, formatting, naming preferences, and docs-only changes.

**Review these categories:**
- **Security**: hardcoded secrets, PII in logs, missing auth guards, SQL injection, unsafe deserialization
- **Correctness**: logic errors, wrong API calls, missing error handling, broken migrations
- **Regression**: deleted code unrelated to the PR, phantom imports, weakened validation
- **Test gaps**: new endpoints or service methods with zero test coverage

**Skip these:**
- Formatting, lint style, import order (handled by CI)
- Comment style, variable naming preferences
- Pure config/lockfile/docs changes
- Suggestions that are "could be nicer" but not wrong

**Severity labels:**
- `critical` — will crash, break auth, leak data, or block deploy
- `medium` — likely bug, risky migration, missing test for new endpoint
- `light` — only include if it's a one-line fix with clear impact

## Step 5: Output

Write findings to the generated `findings.json` with fields: `severity`, `path`, `line`, `title`, `body`, `suggestion`, `security`.

If viewer is PR author, output findings only and stop.

Otherwise run the generated `submit` command; `critical`/`medium` findings request changes, only `light` or none approves.

**Output format — keep it compact:**

```
## PR Review — #{N}

| | |
|---|---|
| **Repo** | {repo} |
| **Files changed** | {N} (+{A}/-{D}) |
| **Findings** | {N} ({C} critical, {M} medium, {L} light) |

### Critical ({N})
1. `path:line` — **title**
   body
   → suggestion

### Medium ({N})
...

### Light ({N})
...

---
No blocking issues.
```

Omit empty sections. If no findings, output only the metadata table and the "No blocking issues" line.

Return only the review result, findings count, and PR URL.

## Do not skip

- Do not skip the `gh auth status` check. If `gh` is not available, stop and report it.
- Do not post comments directly. Always use the `submit` command, which creates a pending review and submits it in two steps.
- Do not skip the repo rules check. Even a quick review should respect the repo's conventions.
- Do not review under time pressure by lowering your standards. If the PR is small and clean, say so — don't invent findings.
- Do not include style, formatting, or "could be nicer" suggestions in a quick pass. Those belong in `/pr-review-deep`.
