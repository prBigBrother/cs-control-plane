---
description: Fetch concise recent PR feedback, with explicit full/raw modes.
---

Usage: `/pr-comments [--full|--raw] <repo> <pr-number>`

Run `./.opencode/bin/pr-comments [flags] <repo> <pr-number>` directly. Default to concise recent feedback; use `--full` only when complete prose is requested and `--raw` only for machine processing. Return the helper output without re-expanding it.
