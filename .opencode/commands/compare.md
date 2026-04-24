Compare the currently deployed SHA in `ops` against a target service SHA.

Fast path:
- Do not delegate this command to an agent.
- Parse the arguments locally, normalize `prod` to `production`, and run the script directly.
- Return only the script output plus any actionable error.

Usage:
`/compare <service> <environment> [target-sha]`

Rules:
- Run `./bin/compare <service> <environment> [target-sha]`.
- Accept `prod` as an alias for `production`.
- Return the script output directly.
