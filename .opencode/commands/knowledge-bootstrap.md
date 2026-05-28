---
description: Build the filtered first Graphify knowledge graph.
---

Usage: `/knowledge-bootstrap [--dry-run|--extract|--merge-existing] [--smoke] [--skip-control-docs]`

Run `./.opencode/bin/knowledge-bootstrap [args]`.

Rules:
- Default to dry-run unless the user explicitly asks to extract.
- Use `--smoke --extract` before the full extraction.
- Use `--merge-existing --no-cluster --skip-control-docs` when extraction finished but raw graph merge failed.
- Use `--skip-control-docs` only for offline product-code validation.
- Do not run raw `graphify extract .` from the control-plane root.
- Keep `odin` excluded and product repo non-code files filtered out for v1.
- For the default OpenAI backend, Graphify must be installed with `uv tool install graphifyy --with openai --force`.
- Raw graph merges normalize temporary bootstrap corpus IDs before writing `graphify-out/merged-graph.json`.
- Return included repos, code counts, control-doc estimate, output path, and any Graphify failure.
