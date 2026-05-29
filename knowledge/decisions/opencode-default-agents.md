# OpenCode Default Agents

## Decision

Control-plane OpenCode profiles default to `manager`.

Repo and worktree OpenCode profiles default to `explorer`.

The built-in `build` agent is disabled in every shared OpenCode profile.

## Rationale

The control plane is an orchestration surface, so Manager should be the first agent users see there. Repo worktrees should start in Explorer because implementation should be scoped by issue context, Graphify output, and targeted reads before edits. Disabling Build prevents accidental use of the broad built-in primary agent and keeps users on the project-specific agent set.
