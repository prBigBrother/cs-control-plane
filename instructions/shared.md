# Shared OpenCode Instructions

- This control plane supports multiple repositories that form one product.
- Use repo-specific worktrees for implementation and keep sessions scoped to one repo worktree whenever possible.
- Treat the control plane as a shared policy and tooling surface, not the main coding location.
- Keep cross-repo orchestration concise. Pass only the smallest necessary context between sessions.
- Use one editing agent per repo worktree. Do not let multiple agents edit the same repo at once.
- Prefer stable scripts and tools under `bin/` and `.opencode/tools/` over ad hoc shell commands.
