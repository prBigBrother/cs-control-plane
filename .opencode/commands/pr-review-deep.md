---
description: Deep multi-agent PR review — delegates to the repo's pr-review skill. Use for thorough review of complex PRs. For a quick sanity check, use `/pr-review`.
---

Usage: `/pr-review-deep <pr-url>`

## Step 1: Verify prerequisites

Confirm `gh` is installed and authenticated:

```bash
gh auth status
```

If `gh` is not installed, stop and tell the user to install it from https://cli.github.com/.

## Step 2: Detect repo

Extract the repo slug from the PR URL (e.g. `citizenshipper/daedalus` → `daedalus`).

## Step 3: Load the repo's pr-review skill

Check for the repo's pr-review skill at one of these paths (in order):
- `repos/<repo>/.opencode/skills/pr-review/SKILL.md`
- `repos/<repo>/.claude/skills/pr-review/SKILL.md`

If found, read the skill and follow its protocol exactly. The skill will coordinate subagents, load repo-specific rules, and produce a consolidated report.

If no skill is found, fall back to `/pr-review` (quick pass) and inform the user.

## Step 4: Run the review

Follow the skill's steps. Typical flow:
1. Fetch PR diff, metadata, and existing comments
2. Launch parallel subagents (security, requirements, tests, architecture, regression, performance)
3. Consolidate findings, deduplicate, and present a draft report
4. Ask the user whether to post findings to the PR

## Step 5: Output

Return the consolidated review report. Do not post to GitHub unless the user explicitly approves.

**Output format — keep it compact:**

```
## PR Review — #{N}

| | |
|---|---|
| **Repo** | {repo} |
| **Files changed** | {N} (+{A}/-{D}) |
| **Findings** | {N} across {M} files |

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

Omit empty severity sections. If no findings, output only the metadata table and the "No blocking issues" line.

## Do not skip

- Do not skip the `gh auth status` check. If `gh` is not available, stop and report it.
- Do not post anything to GitHub without explicit user approval. Present the draft, then ask.
- Do not skip the repo skill. If a skill exists, follow it — it knows the repo's conventions.
- Do not skip subagents whose scope the diff touches. If the diff touches tests, run the test subagent. If it touches auth, run security.
- Do not post under time pressure. The deep review is thorough by design — rushing defeats the purpose.
