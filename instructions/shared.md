# Shared OpenCode Instructions

- This control plane supports multiple repositories that form one product.
- Use repo-specific worktrees for implementation and keep sessions scoped to one repo worktree whenever possible.
- Treat the control plane as a shared policy and tooling surface, not the main coding location.
- Keep cross-repo orchestration concise. Pass only the smallest necessary context between sessions.
- When the user mentions an `ENG-<id>` task and the Linear issue details are not already present in the conversation, fetch that Linear issue before repo investigation, worktree setup, or implementation.
- Treat repo hints such as "in odin" as routing hints only; use Linear as the task source of truth for title, description, acceptance criteria, labels, priority, status, links, and comments.
- If Linear is unavailable or the issue cannot be found, state that blocker before falling back to repo-only investigation.
- Use one editing agent per repo worktree. Do not let multiple agents edit the same repo at once.
- Prefer stable scripts and tools under `bin/` and `.opencode/tools/` over ad hoc shell commands.
- Prefer fast script-backed slash commands for deterministic control-plane work; reserve subagents for repo discovery, implementation, validation, migration audits, and cross-repo coordination.
- Use scoped OpenCode profiles to keep default context small:
  - `engineering`: shared engineering rules only
  - `migration`: engineering plus migration rules
  - `release`: engineering plus release rules
  - `external`: engineering plus remote MCP integrations
  - `full`: all shared rules plus remote MCP integrations
