#!/usr/bin/env python3
"""Generate compact OpenCode MCP config snippets."""

from __future__ import annotations

import argparse
import json
import re
import shlex


def safe_name(value: str) -> str:
    name = value.strip().lower().replace("-", "_")
    name = re.sub(r"[^a-z0-9_]+", "_", name)
    name = re.sub(r"_{2,}", "_", name).strip("_")
    if not name:
        raise SystemExit("MCP name cannot be empty")
    return name


def parse_env(values: list[str]) -> dict[str, str]:
    result: dict[str, str] = {}
    for item in values:
        if "=" not in item:
            key = item
            value = f"{{env:{item}}}"
        else:
            key, value = item.split("=", 1)
        key = key.strip()
        if not key:
            raise SystemExit(f"invalid env entry: {item!r}")
        result[key] = value.strip()
    return result


def build_config(args: argparse.Namespace) -> dict[str, object]:
    name = safe_name(args.name)
    server: dict[str, object] = {"type": args.type}

    if args.type == "remote":
        if not args.url:
            raise SystemExit("--url is required for remote MCP servers")
        server["url"] = args.url
        if args.oauth:
            server["oauth"] = {} if args.oauth == "auto" else False
        if args.header:
            server["headers"] = parse_env(args.header)
    else:
        if not args.command:
            raise SystemExit("--command is required for local MCP servers")
        server["command"] = shlex.split(args.command)
        if args.env:
            server["environment"] = parse_env(args.env)

    if args.enabled is not None:
        server["enabled"] = args.enabled == "true"
    if args.timeout is not None:
        server["timeout"] = args.timeout

    return {"mcp": {name: server}}


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate an OpenCode MCP config snippet."
    )
    parser.add_argument("name", help="MCP server name, for example context7")
    parser.add_argument("--type", choices=("remote", "local"), required=True)
    parser.add_argument("--url", help="Remote MCP URL")
    parser.add_argument(
        "--command",
        help='Local MCP command, for example: "npx -y my-mcp"',
    )
    parser.add_argument("--env", action="append", default=[], help="KEY or KEY=value")
    parser.add_argument("--header", action="append", default=[], help="KEY or KEY=value")
    parser.add_argument("--enabled", choices=("true", "false"))
    parser.add_argument("--timeout", type=int)
    parser.add_argument(
        "--oauth",
        choices=("auto", "false"),
        help="For remote servers: auto emits oauth: {}, false emits oauth: false",
    )
    args = parser.parse_args()

    print(json.dumps(build_config(args), indent=2, sort_keys=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
