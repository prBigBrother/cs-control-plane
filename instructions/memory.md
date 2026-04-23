# Memory Instructions

- Shared memory is intended for durable, high-signal facts only.
- Allowed memory categories:
  - architecture decisions
  - migration decisions
  - repo conventions
  - validated runbook outcomes
- Prohibited memory categories:
  - secrets and credentials
  - source code blobs
  - raw diffs
  - unsanitized logs
- Namespace memories by scope:
  - `workspace/citizenshipper`
  - `repo/<name>`
  - `migration/<domain>`
  - `ticket/ENG-<id>`
