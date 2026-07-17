---
description: Build the filtered Graphify knowledge graph.
---

Usage: `/knowledge-bootstrap [--dry-run|--extract|--merge-existing] [--smoke] [--skip-control-docs]`

Run `./.opencode/bin/knowledge-bootstrap [args]`; default to dry-run. Before full extraction, use `--smoke --extract`. Use `--merge-existing --no-cluster --skip-control-docs` only to repair a completed raw merge, and never run raw extraction at the control-plane root. Keep Odin excluded. If OpenAI support is missing, report `uv tool install graphifyy --with openai --force`. Return corpus counts, output path, and first failure.
