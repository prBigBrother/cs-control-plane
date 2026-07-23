---
description: Ask a graph-first architecture, flow, dependency, or impact question.
---

Usage: `/knowledge [--scope auto|all|control-plane|repo] <question>`

Run `./.opencode/bin/knowledge-query $ARGUMENTS`. Auto guards control-plane questions from unrelated product nodes while preserving cross-repo queries; pass an explicit scope when needed. Report `Graphify: queried|blocked` and `Source: verified|blocked` separately. Verify important graph claims in source. If no graph exists, give the exact `/knowledge-bootstrap` command and permit only labeled source-only fallback. Never extract or update. Return flow, paths, runtime surfaces, risks, and open questions.
