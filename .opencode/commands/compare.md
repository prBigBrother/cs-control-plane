---
description: Compare the deployed ops SHA against a target service SHA.
---

Usage: `/compare <service> <environment> [target-sha]`

Run `./.opencode/bin/compare <service> <environment> [target-sha]`.

Rules:
- Do not delegate.
- Accept `prod` as `production`.
- Return the script Markdown summary directly, plus actionable errors only.
