---
description: Ask a graph-first architecture, flow, dependency, or impact question.
---

Usage: `/knowledge [--scope auto|all|control-plane|repo] <question>`

Run `./.opencode/bin/knowledge-query $ARGUMENTS`. When the question names one product repo, add `--scope <repo>`; use `--scope all` only for intentional cross-repo questions. Query stable route, hook, API, or domain symbols, excluding runtime UUIDs, IDs, and broad incident prose. Auto guards control-plane questions from unrelated product nodes. Report `Graphify: queried|blocked` and `Source: verified|blocked` separately. Verify important graph claims in source. If no graph exists, give the exact `/knowledge-bootstrap` command and permit only labeled source-only fallback. Never extract or update. Return flow, paths, runtime surfaces, risks, and open questions.
