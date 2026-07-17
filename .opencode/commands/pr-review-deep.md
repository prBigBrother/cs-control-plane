---
description: Deep multi-agent review for complex or high-risk PRs; use pr-review for a quick pass.
---

Usage: `/pr-review-deep <pr-url>`

Run `./.opencode/bin/pr-review skill <pr-url>`, read the returned repo skill, and follow it exactly. It owns rules, specialist routing, deduplication, and report shape. If absent, run `/pr-review <pr-url>` and identify the fallback.

Return an evidenced draft only. Never post, approve, or request changes until the user approves it; then use the skill's posting flow. Include every specialist whose risk surface the diff touches.
