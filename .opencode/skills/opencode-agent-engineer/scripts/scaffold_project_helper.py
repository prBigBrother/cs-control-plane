#!/usr/bin/env python3
"""Create a small project helper script for repeated agent workflows."""

from __future__ import annotations

import argparse
import os
import re
from pathlib import Path


def safe_name(value: str) -> str:
    name = value.strip().lower().replace("_", "-")
    name = re.sub(r"[^a-z0-9.-]+", "-", name)
    name = re.sub(r"-{2,}", "-", name).strip("-")
    if not name:
        raise SystemExit("helper name cannot be empty")
    if "/" in name or name in {".", ".."}:
        raise SystemExit("helper name must be a single file name")
    return name


def bash_template(name: str, description: str) -> str:
    return f"""#!/usr/bin/env bash
set -euo pipefail

usage() {{
  cat <<'USAGE'
{name}: {description}

Usage:
  {name} [--help]

Options:
  --help    Show this help message.
USAGE
}}

main() {{
  case "${{1:-}}" in
    --help|-h)
      usage
      return 0
      ;;
  esac

  echo "TODO: implement {name}"
}}

main "$@"
"""


def python_template(name: str, description: str) -> str:
    return f'''#!/usr/bin/env python3
""" {description} """

from __future__ import annotations

import argparse


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="{name}", description="{description}")
    return parser.parse_args()


def main() -> int:
    parse_args()
    print("TODO: implement {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
'''


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scaffold a reusable project helper script."
    )
    parser.add_argument("name", help="Helper command name, for example create-pr")
    parser.add_argument("--project-root", default=".", help="Project root directory")
    parser.add_argument("--dir", default="bin", help="Output directory under project root")
    parser.add_argument(
        "--kind", choices=("bash", "python"), default="bash", help="Script type"
    )
    parser.add_argument(
        "--description",
        default="Project helper for a repeated agent workflow.",
        help="One-line command description",
    )
    parser.add_argument("--force", action="store_true", help="Overwrite existing file")
    args = parser.parse_args()

    name = safe_name(args.name)
    root = Path(args.project_root).resolve()
    out_dir = root / args.dir
    path = out_dir / name

    if path.exists() and not args.force:
        raise SystemExit(f"{path} already exists; pass --force to overwrite")

    out_dir.mkdir(parents=True, exist_ok=True)
    content = (
        bash_template(name, args.description)
        if args.kind == "bash"
        else python_template(name, args.description)
    )
    path.write_text(content)
    path.chmod(path.stat().st_mode | 0o755)
    print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
