# MCP Organization

Use this reference when adopting, suggesting, auditing, or organizing MCP servers for OpenCode agents. Always verify current syntax with `https://opencode.ai/docs/mcp-servers/` before editing config.

Verified from the official docs on 2026-05-26.

## Decision Model

Classify each candidate MCP as:

- Adopt: required for a repeated workflow and better than built-in tools, helper scripts, or a small custom tool.
- Suggest: useful in some workflows, but needs user confirmation because it adds context, credentials, cost, or network dependency.
- Defer: not enough benefit, overlaps with existing tooling, too broad, or likely to waste context.

For each recommendation, state:

- Job it solves.
- Config location: project-local or global.
- Enablement: always enabled, disabled by default, or per-agent only.
- Auth or env vars required.
- Context/token risk: low, medium, or high.
- Alternative: built-in tool, bash/Python helper, or OpenCode custom tool.

## Organization Rules

- Keep MCP names stable and obvious. Prefer `context7`, `sentry`, `linear`, `github`, or `<vendor>_<capability>`.
- Group related MCP entries under the `mcp` key in `opencode.json` or `opencode.jsonc`.
- Prefer project-local config for repo-specific vendors, internal APIs, staging tools, or narrow workflows.
- Prefer global config for tools the user wants across many projects.
- Disable high-volume MCP servers globally when possible and enable them only for the agents that need them.
- Store secrets in environment variables and reference them from config; never inline API keys.
- Include `timeout` when slow startup or remote latency is expected.
- Add `AGENTS.md` guidance only for routing behavior the user should invoke intentionally, such as "use context7 for framework docs."

## Local MCP Checklist

- `type` is `local`.
- `command` is an array of command and arguments.
- Required environment variables are listed under `environment`.
- `enabled` is set intentionally.
- Startup command is available through project or global tooling.
- The server's tool count is acceptable for the intended agent.

## Remote MCP Checklist

- `type` is `remote`.
- `url` points to the server endpoint.
- `oauth` is configured or intentionally disabled when using API-key headers.
- Headers use env references.
- Authentication command is documented for the user when needed.
- Network and credential requirements are clear.

## Common Recommendation Patterns

- Docs lookup: suggest Context7 when framework/library documentation lookup is frequent; otherwise use normal web/docs lookup.
- Observability: suggest Sentry or Datadog-like MCP only for agents that triage production issues or error reports.
- Project management: suggest Linear/Jira MCP only when agent workflows must read or update tickets repeatedly.
- GitHub: suggest cautiously because broad GitHub MCPs can add substantial context; prefer `gh` helper scripts for PR creation and deterministic repository flows.
- Code search: suggest Grep-like MCP for external code examples; prefer `rg` for local repository search.

## Config Snippet Workflow

1. Read current OpenCode MCP docs.
2. Decide local vs remote.
3. Draft the smallest config snippet.
4. Add env placeholders instead of secrets.
5. Decide global vs per-agent enablement.
6. Add auth commands or validation commands to the final report.
7. Suggest a helper script when setup or validation will repeat.
