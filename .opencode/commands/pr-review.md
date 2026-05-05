Run a qualified GitHub pull request review from a PR URL.

Fast path:
- From a repo worktree, use `./.opencode/bin/pr-review collect <pr-url>` first to gather metadata, files, comments, and diff into control-plane `tmp/`.
- From the control plane, use `./bin/pr-review collect <pr-url>`.
- Read the generated `packet.md` and `diff.patch`; inspect code carefully before deciding findings.
- Do not post comments, approvals, or change requests when the collected context says the viewer is the PR author. In that case, output findings only.
- For someone else's PR, write findings to the generated `findings.json` path and run the matching `submit` command from the same session path.

Usage:
`/pr-review <pr-url>`

Severity rules:
- Mark all security issues as `critical`.
- Use `critical` for vulnerabilities, data loss, privacy leaks, auth/permission bypass, crashes, severe regressions, or broken deployment/release behavior.
- Use `medium` for likely correctness bugs, missing important validation, incomplete requirements, risky migrations, unhandled edge cases, or meaningful test gaps.
- Use `light` for style, small maintainability issues, minor docs gaps, naming, or non-blocking cleanup.

Review outcome:
- If any finding is `critical` or `medium`, submit a change-request review.
- If findings are only `light`, submit an approval review with comments.
- If there are no findings, submit an approval review.
- If the PR is authored by the current GitHub user, output findings only and do not call `submit`.

Finding JSON schema:
```json
[
  {
    "severity": "critical",
    "path": "src/file.ts",
    "line": 123,
    "title": "Short issue title",
    "body": "Explain the issue, impact, and suggested fix.",
    "suggestion": "Short fix direction.",
    "security": true
  }
]
```

Rules:
- Every finding should point to a concrete file and line when possible.
- Review comments should start with a bold severity/title line, for example `**MEDIUM: Missing null guard**`.
- Include a short `suggestion` for every actionable finding unless the fix is completely obvious from the comment body.
- Keep comments concise and actionable.
- Avoid repeating existing review comments unless the issue remains unresolved or needs a stronger severity.
- Format URLs as Markdown links unless quoting raw command output.
