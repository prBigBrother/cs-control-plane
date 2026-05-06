Run two curl commands, normalize their response bodies, and return Markdown context for a migration-fix agent.

Fast path:
- Do not delegate this command to an agent.
- Require exactly two quoted curl commands.
- Run the script directly and return its output plus any actionable error.

Usage:
`/compare-curl '<curl ...>' '<curl ...>'`

Optional:
- `/compare-curl --format text '<curl ...>' '<curl ...>'`
- `/compare-curl --context 5 '<curl ...>' '<curl ...>'`
- `/compare-curl --left-label local --right-label staging '<curl ...>' '<curl ...>'`
- `/compare-curl --no-line-diff '<curl ...>' '<curl ...>'`

Rules:
- Run `./bin/compare-curl [options] '<curl ...>' '<curl ...>'`.
- Markdown is the default output format; return it exactly as produced as agent context.
- Treat the first curl as `local` and the second curl as `staging` unless labels are explicitly provided.
- The purpose of the report is to help an agent update local behavior so it matches staging.
- JSON responses are parsed, recursively sorted by object key, array items are recursively sorted, and the result is pretty-printed before comparison.
- For JSON responses, return the `Agent Fix Context` section because it explains what local must change to match staging.
- Non-JSON responses are compared as normalized text.
- Keep the line-numbered diff inside its fenced `diff` block so newlines and indentation are preserved.
- Return the Markdown objective, response snapshot, agent fix context, and evidence diff directly.
