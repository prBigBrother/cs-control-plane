---
name: opencode-agent-engineer
description: Create, manage, review, and optimize OpenCode agents, subagents, helper scripts, MCP servers, permissions, prompts, AGENTS.md rules, opencode.json configuration, and OpenCode skills. Use when Codex needs to design token-efficient agent behavior, adopt or organize MCP servers, suggest appropriate MCP integrations, automate repeated agent/project workflows with bash or Python scripts, reduce prompt or output size, improve agent routing, choose OpenCode agent modes or permissions, or update OpenCode agent files using the current official OpenCode documentation.
---

# OpenCode Agent Engineer

Use this skill to create or improve OpenCode agents with current docs, least-privilege configuration, and concise prompts.

## Non-Negotiables

- Use the official OpenCode docs before changing OpenCode-specific syntax, paths, permissions, config fields, or workflow recommendations.
- Read `references/opencode-doc-routing.md` first, then open the exact docs page(s) relevant to the task.
- Read `references/automation-first.md` when a workflow might be repeated or can be replaced by a project helper script.
- Read `references/mcp-organization.md` when adopting, suggesting, auditing, enabling, disabling, or organizing MCP servers.
- Ask the user a clarifying question before implementation when the goal is unclear, the target location is ambiguous, or multiple materially different implementations are valid.
- Prefer the smallest effective agent surface: focused description, focused prompt, minimal permissions, bounded steps when useful, and no redundant instructions.
- Automate repeated project workflows as bash or Python helpers before adding long instructions to an agent prompt.
- Do not rely on legacy `tools` config for non-MCP agent permissions when current docs support `permission`; for MCP enable/disable behavior, follow the current MCP docs.

## Workflow

1. Classify the request:
   - New agent, agent update, MCP adoption, MCP recommendation, MCP organization, project helper script, permission review, prompt compression, AGENTS.md rules, OpenCode skill, custom tool, or general config.
2. Load the matching docs route:
   - Read `references/opencode-doc-routing.md`.
   - Open the listed official docs page(s) and verify current field names and paths.
3. Inspect existing project files before editing:
   - Check for `opencode.json`, `opencode.jsonc`, `.opencode/agents/`, `.opencode/skills/`, `.opencode/tools/`, `AGENTS.md`, `bin/`, `scripts/`, `Makefile`, `Justfile`, package scripts, and relevant prompt files.
   - For global work, check `~/.config/opencode/` only when the user asks for global configuration or no project-local target is intended.
4. Run the automation-first pass:
   - Identify any repeated shell steps, file scans, GitHub flows, validation loops, prompt rewrites, docs lookups, or report generation.
   - Prefer creating or updating a project helper such as `bin/create-pr`, `bin/check-agent`, `bin/agent-audit`, or `scripts/<task>.py` when it will save future tokens.
   - Use this skill's `scripts/scaffold_project_helper.py` to create helper boilerplate when useful.
   - Keep agent instructions short by telling the agent to run the helper and summarize its result.
5. Run the MCP pass when relevant:
   - Identify the job the MCP server solves, the expected tool volume, required credentials, and whether it should be global or per-agent.
   - Prefer no MCP when built-in tools, project scripts, or a small custom tool solve the job with less context.
   - Prefer disabled globally and enabled only for specific agents when an MCP exposes many tools or is rarely needed.
   - Use this skill's `scripts/mcp_config_helper.py` to draft local or remote MCP config snippets when useful.
6. Choose the narrowest implementation:
   - Use Markdown agents for self-contained agents.
   - Use `opencode.json` when changing built-ins, shared model defaults, permission policy, or multiple agents together.
   - Use separate prompt files only when the prompt is long, reused, or easier to maintain out of config.
   - Use project helper scripts for deterministic repeated operations.
   - Use MCP servers when they provide durable external capability that should be exposed to OpenCode tools.
7. Implement and validate:
   - Preserve existing config and user edits.
   - Make new helper scripts executable when the platform supports it.
   - Validate JSON/JSONC syntax when touched.
   - Run or dry-run helper scripts with safe arguments before relying on them.
   - For MCP changes, verify server names, `type`, `url` or `command`, env references, `enabled`, timeout, and auth steps against current docs.
   - If OpenCode is installed, prefer OpenCode-native validation commands when available.
   - Report files changed, docs checked, and any assumptions.

## Agent Design Rules

- Write the `description` as routing metadata: what the agent does and when to use it.
- Keep the system prompt procedural and short. Include only behavior the base model would not infer.
- Use `mode: primary` for direct user workflows, `mode: subagent` for delegated specialist work, and `mode: all` only when both are intentional.
- Set `permission` by capability, not convenience:
  - Review, planning, and docs agents usually deny `edit`.
  - Research agents may allow `webfetch` or `websearch` but deny edits.
  - Builders should ask before risky shell commands or broad task delegation.
- Use `permission.task` to limit which subagents an orchestrator can call.
- Use low temperature for analysis, review, planning, migration, and deterministic coding.
- Use `steps` for cost-sensitive or tightly scoped agents.
- Use `hidden: true` only for internal subagents that should not appear in normal autocomplete.
- Replace procedural prompt blocks with commands when a helper exists, for example: "Run `bin/create-pr` and report the PR URL and failed checks."

## MCP Server Rules

- Treat MCP servers as context-expensive capabilities; add them only when they provide a clear capability that built-in tools or helper scripts cannot cover cleanly.
- Recommend MCP servers by job-to-be-done, not popularity. State what the MCP unlocks, expected token/context cost, credential needs, and safer alternatives.
- Organize MCP config with stable, descriptive names such as `context7`, `sentry`, `linear`, `github`, or `<vendor>_<capability>` when multiple servers from a vendor exist.
- Prefer project-local MCP config when the server is needed only for that repository; prefer global config only for broadly useful personal tooling.
- For local MCP servers, prefer explicit command arrays and environment variable references rather than inline secrets.
- For remote MCP servers, prefer OAuth when the server supports it; use env-backed headers for API keys.
- Disable broad or rarely used MCP servers globally, then enable them only for agents that need them when current OpenCode docs support that pattern.
- Add a short AGENTS.md rule only when users should remember to request a specific MCP, for example docs lookup through Context7.
- Never add secrets directly to config files.

## Automation-First Rules

- Create or improve a helper script when the same sequence is likely to be run more than once or takes more than a few prompt bullets to describe.
- Prefer bash for thin wrappers around existing CLIs and Python for parsing, file rewrites, JSON/JSONC handling, multi-step validation, or generated reports.
- Put project-local helpers in `bin/` by default when they are human-facing commands. Use `scripts/` for library-like or CI-only helpers if the project already follows that pattern.
- Make helpers composable: accept flags, print concise output, exit non-zero on failure, and avoid interactive prompts unless explicitly requested.
- Keep helpers source-controlled and documented by their own `--help` output, not by long agent instructions.
- For GitHub PR creation, prefer a project command such as `bin/create-pr` that wraps the approved local flow: status checks, branch validation, title/body generation, `gh pr create`, and final URL reporting.
- For agent improvement loops, prefer helpers that measure prompt size, list repeated instructions, validate config, and produce a compact findings report.
- Use OpenCode custom tools only when the helper must be callable as an OpenCode tool with structured inputs; otherwise prefer normal project scripts.

## Token And Output Efficiency

- Remove generic role prose, praise, restated policies, and examples that do not change behavior.
- Prefer checklists and decision rules over long explanations.
- Move detailed docs, examples, schemas, or reusable text into separate files and reference them only when needed.
- Move repeated deterministic work into scripts, then replace instructions with "run `<command>`".
- Keep agent prompts single-purpose. Split broad agents into an orchestrator plus small subagents only when routing overhead is justified.
- Tell agents what to omit: no long summaries, no duplicated command output, no full-file rewrites unless needed.
- When improving an existing agent, produce a before/after summary of token-saving changes instead of rewriting unrelated sections.

## Clarifying Questions

Ask before editing when any of these are unresolved:

- Global vs project-local agent location.
- Primary agent vs subagent behavior.
- Whether the agent may edit files, run shell commands, search the web, or invoke other agents.
- Whether a helper script should be project-local, global, or embedded as an OpenCode custom tool.
- Which MCP server or external system is intended, whether credentials are available, and whether it should be global, project-local, or per-agent.
- Model/provider choice when cost, speed, or reasoning depth matters.
- Desired output style when the user asks for efficiency but not the tradeoff.

If a reasonable default is safe, state the assumption and continue only when the choice is reversible and low-risk.

## Common Outputs

- Markdown agent file in `.opencode/agents/<name>.md`.
- OpenCode config patch in `opencode.json` or `opencode.jsonc`.
- Prompt file referenced with `{file:./path/to/prompt.txt}`.
- Project rules in `AGENTS.md`.
- OpenCode skill in `.opencode/skills/<name>/SKILL.md`.
- Project helper script such as `bin/create-pr`, `bin/check-agent`, `bin/agent-audit`, or `scripts/<task>.py`.
- MCP config under `mcp` in `opencode.json` or `opencode.jsonc`, plus per-agent/global enablement rules when appropriate.
- MCP recommendation matrix with adopt/suggest/defer decisions.
- Review report with specific efficiency, routing, permission, and docs-compliance findings.
