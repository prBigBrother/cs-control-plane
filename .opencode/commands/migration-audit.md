---
description: Run a migration-oriented audit across legacy and target repos.
---

Usage: `/migration-audit <feature-area>`

Delegate to the `auditor` agent when available.

Rules:
- Pass the full slash-command invocation unchanged.
- Include `dinah` as a read-only source.
- Include likely targets such as `daedalus`, `icarus`, `ops`, and `olympus` when relevant.
- Return only the consolidated audit, focused on dependencies, flags, routes, data ownership, rollout points, and cleanup targets.
