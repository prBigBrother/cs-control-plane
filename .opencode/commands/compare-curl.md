---
description: Compare two curl responses and return compact migration-fix context.
---

Usage:
- `/compare-curl '<curl ...>' '<curl ...>'`
- `/compare-curl <raw pasted local curl> <raw pasted staging curl>`

Run `./bin/compare-curl [options] '<curl ...>' '<curl ...>'`.

Rules:
- If the user pastes raw curls, save them to `tmp/compare-curl-input.txt` and run `./bin/compare-curl --input-file tmp/compare-curl-input.txt`.
- Treat the first curl as `local` and the second as `staging` unless labels are provided.
- Return the script Markdown directly.
- Default output is compact; use `--line-diff` only when evidence lines are needed.
- If either request fails or returns HTTP 4xx/5xx, return diagnostics and skipped-diff reason only.
