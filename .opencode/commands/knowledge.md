---
description: Ask a graph-first codebase question against the shared Graphify graph.
---

Usage: `/knowledge <question>`

Run `./.opencode/bin/knowledge-query "$ARGUMENTS"`.

Rules:
- Use this for architecture, flow, dependency, impact, or "how A connects to B" questions.
- Run the helper first, then verify important claims with targeted file reads.
- Do not run extraction, update, bootstrap, or hooks from this command.
- Keep the answer concise: flow map, file paths, runtime surfaces, risks, and open questions.
