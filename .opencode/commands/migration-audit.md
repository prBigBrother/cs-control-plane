Run a migration-oriented audit across legacy and target repos.

Usage:
`/migration-audit <feature-area>`

Rules:
- Include `dinah` as a read-only source.
- Include likely target repos such as `daedalus`, `icarus`, `ops`, and `olympus` when relevant.
- Focus on dependencies, flags, routes, data ownership, rollout points, and cleanup targets.
