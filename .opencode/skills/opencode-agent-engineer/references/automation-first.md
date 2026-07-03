# Automation-First Agent Work

Use this reference when improving an OpenCode agent would otherwise require long procedural instructions. Prefer turning repeated work into executable project helpers, then keep agent prompts short.

## Script Threshold

Create or update a helper script when any condition is true:

- The workflow is likely to run more than once.
- The prompt needs more than 5 bullets to describe deterministic shell, parsing, or validation steps.
- The task requires repeated `rg`, `git`, `gh`, package-manager, JSON, or filesystem operations.
- The output can be summarized from command results instead of generated from memory.
- The agent has previously spent tokens repeating the same instructions, checks, or report format.

## Default Locations

- Use `bin/<command>` for human-facing project commands, for example `bin/create-pr`.
- Use `scripts/<task>.py` for implementation-heavy or CI-only helpers if the repo already has a `scripts/` convention.
- Use `.opencode/tools/<name>.ts` only when the helper must be an OpenCode custom tool with structured input and tool permission handling.
- Prefer existing conventions over introducing a new folder.

## Helper Requirements

- Provide `--help`.
- Accept flags instead of asking interactive questions.
- Print concise, stable output.
- Exit non-zero on failure.
- Avoid network calls unless the command purpose clearly requires them.
- Avoid destructive changes unless the user explicitly asked for them.
- Keep generated PR bodies, reports, and summaries compact by default, with a `--verbose` flag if needed.

## Common Helpers

- `bin/create-pr`: validate branch state, collect changed files, run configured checks when requested, generate a concise PR title/body, call `gh pr create`, and print the PR URL.
- `bin/check-agent`: validate OpenCode agent files, required frontmatter, docs-routed fields, and permission policy.
- `bin/agent-audit`: count prompt lines, find repeated generic instructions, flag broad permissions, and suggest script extraction.
- `bin/opencode-docs`: open or print the exact OpenCode docs page for a task keyword.
- `bin/agent-test`: run deterministic fixtures or dry-runs for an agent workflow.

## Prompt Replacement Pattern

Replace long instructions like:

```text
Check git status, inspect changed files, draft a title, build a PR body, run gh pr create, then report the link.
```

with:

```text
Run `bin/create-pr` with the appropriate flags. Report the PR URL, failed checks, and any assumptions.
```

## Scaffolding

Use `scripts/scaffold_project_helper.py` from this skill to create a safe starter helper, then edit the generated command to match the project workflow.
