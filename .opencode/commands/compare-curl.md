---
description: Compare two curl responses and return migration-fix context.
---

Usage: `/compare-curl '<curl ...>' '<curl ...>'`

Run `./.opencode/bin/compare-curl [options] '<local-curl>' '<staging-curl>'`. For pasted multiline curls, save them under `tmp/` and use `--input-file`. Return the helper's compact Markdown. Add `--line-diff` only when evidence lines are needed. If a request fails or returns 4xx/5xx, report diagnostics and the skipped-diff reason; do not infer a body diff.
