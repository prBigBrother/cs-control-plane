# OpenCode Docs Routing

Use this routing file before creating, editing, or reviewing OpenCode agents. Open the current official docs page at `https://opencode.ai/docs/` or the exact route below before relying on a field name, path, or behavior.

Verified from the official docs index on 2026-05-26.

## Core Pages

- Agent creation, built-in agents, modes, Markdown agent files, descriptions, permissions, `steps`, `hidden`, `permission.task`, temperature, model, and provider-specific options:
  `https://opencode.ai/docs/agents/`
- OpenCode skills, discovery paths, `SKILL.md` frontmatter, name rules, length rules, and skill permissions:
  `https://opencode.ai/docs/skills/`
- Project and global rule files, `/init`, `AGENTS.md`, Claude Code compatibility, and rule precedence:
  `https://opencode.ai/docs/rules/`
- `opencode.json` / `opencode.jsonc`, config locations, merge precedence, schema, variables, and global vs project config:
  `https://opencode.ai/docs/config/`
- Built-in tools and tool permission categories:
  `https://opencode.ai/docs/tools/`
- Custom TypeScript tools in `.opencode/tools/`, `tool()` helper, argument schemas, context, and naming:
  `https://opencode.ai/docs/custom-tools/`
- Models and provider/model IDs:
  `https://opencode.ai/docs/models/`
- MCP server configuration, recommendation, adoption, organization, local/remote setup, OAuth, auth commands, global/per-agent enablement, and tool context caveats:
  `https://opencode.ai/docs/mcp-servers/`
- Commands:
  `https://opencode.ai/docs/commands/`
- Formatters:
  `https://opencode.ai/docs/formatters/`

## Task-To-Page Map

- "Create an agent", "edit an agent", "subagent", "primary agent", "review agent", "planner", "orchestrator":
  read Agents first; read Config if using `opencode.json`; read Tools if changing permissions.
- "Make it cheaper", "reduce tokens", "limit output", "avoid loops":
  read Agents for `steps`, model options, and prompt configuration; read Config for global defaults.
- "Can this agent edit files or run commands?":
  read Agents permissions and Tools permissions.
- "Use a skill in OpenCode" or "create OpenCode skill":
  read Agent Skills; read Rules if the skill overlaps with project instructions.
- "Where should this live?":
  read Agents for agent file locations, Skills for skill discovery, Rules for AGENTS.md, Config for precedence.
- "Add a custom integration/tool":
  read Custom Tools; read Tools and Permissions; read MCP Servers if it should be an MCP integration instead.
- "Adopt MCP", "suggest MCP", "organize MCP", "enable MCP", "disable MCP", "per-agent MCP":
  read MCP Servers first; read Config for precedence; read Agents when enabling only for specific agents.
- "Project instructions", "repo rules", "AGENTS.md":
  read Rules; read Config only if instructions are configured via `instructions`.

## Current High-Value Facts To Recheck

- Markdown agent files can be global under `~/.config/opencode/agents/` or project-local under `.opencode/agents/`.
- OpenCode skills are discovered from project-local `.opencode/skills/*/SKILL.md` and global `~/.config/opencode/skills/*/SKILL.md`, with compatibility fallbacks for `.claude/skills` and `.agents/skills`.
- OpenCode config files are merged by precedence; project config overrides global defaults for conflicting keys.
- For new agent/tool access control, prefer `permission`; legacy `tools` is deprecated for new config.
- MCP servers add tool context; broad servers should be adopted carefully and often enabled only where needed.
- Agent `description` is required and should describe both purpose and routing conditions.
