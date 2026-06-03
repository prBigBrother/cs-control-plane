# Repo Agent Unrestricted Bash

Date: 2026-06-02

Decision:
- Allow unrestricted bash for repo `implementer` and `validator` agents.
- Keep unrestricted bash limited to these two repo roles.

Rationale:
- Real validation commands commonly use environment-variable prefixes and pipelines, for example:
  `TS_NODE_FILES=1 LOG_LEVEL=fatal NODE_ENV=test ts-node node_modules/tape/bin/tape "src/modules/users/auth.service.test.ts" | tap-spec`
- Fine-grained command patterns still trigger approval prompts when the full shell expression starts with environment assignments or combines tools through a pipeline.
- Repeated prompts interrupt repo implementation and verification workflows.

Risk:
- `implementer` can execute arbitrary shell commands inside its session.
- `validator` keeps `edit: deny`, but unrestricted bash can technically mutate or delete files. Its no-mutation rule is behavioral rather than technically enforced for shell commands.
- Use these roles only inside task-specific repo worktrees.
