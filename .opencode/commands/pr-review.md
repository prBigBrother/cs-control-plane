---
description: Quick repo-aware PR review; use pr-review-deep for high-risk changes.
---

Usage: `/pr-review <pr-url>`

Run `./.opencode/bin/pr-review collect --trim <pr-url>`. Read its packet, diff, and discovered repo rules; write only evidenced security, correctness, regression, migration, or missing-test findings—never style or invented issues.

Run `./.opencode/bin/pr-review render <context-json> <findings-json>` and present that draft. Never post, approve, request changes, or submit without explicit user approval. After approval, run the helper's `submit --approved`; security is critical, critical/medium requests changes, and light/empty approves. Include outcome and PR link.
