# Shared OpenCode Instructions

- This control plane supports multiple repositories that form one product.
- Use repo-specific worktrees for implementation and keep sessions scoped to one repo worktree whenever possible.
- Treat the control plane as a shared policy and tooling surface, not the main coding location.
- Keep cross-repo orchestration concise. Pass only the smallest necessary context between sessions.
- Use one editing agent per repo worktree. Do not let multiple agents edit the same repo at once.
- Prefer stable scripts and tools under `bin/` and `.opencode/tools/` over ad hoc shell commands.
- Prefer fast script-backed slash commands for deterministic control-plane work; reserve subagents for repo discovery, implementation, validation, migration audits, and cross-repo coordination.
- Use scoped OpenCode profiles to keep default context small:
  - `engineering`: shared engineering rules only
  - `migration`: engineering plus migration rules
  - `release`: engineering plus release rules
  - `external`: engineering plus remote MCP integrations
  - `full`: all shared rules plus remote MCP integrations
