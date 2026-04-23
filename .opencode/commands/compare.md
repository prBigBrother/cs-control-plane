Compare the currently deployed SHA in `ops` against a target service SHA.

Usage:
`/compare <service> <environment> [target-sha]`

Rules:
- Run `./bin/compare <service> <environment> [target-sha]`.
- Accept `prod` as an alias for `production`.
- Return the script output directly.
