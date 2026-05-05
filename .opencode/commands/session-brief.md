Return a compact repo/worktree brief for agent handoff.

Fast path:
- Do not delegate this command to an agent.
- Run the script directly and return the output.
- Use this before spawning repo-scoped agents so repeated discovery starts from the same compact state.

Usage:
`/session-brief [repo-or-worktree-path]`

Rules:
- From a repo worktree, run `./.opencode/bin/session-brief [repo-or-worktree-path]`.
- From the control plane, run `./bin/session-brief [repo-or-worktree-path]`.
- Return path, branch, git status, package scripts, and local instruction presence.
