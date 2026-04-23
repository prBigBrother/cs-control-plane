#!/usr/bin/env node

const profiles = {
  icarus: {
    editable: true,
    worktrees: true,
    branch: "main",
    node: "22.21.1",
    role: "frontend"
  },
  daedalus: {
    editable: true,
    worktrees: true,
    branch: "main",
    node: "22.21.1",
    role: "backend"
  },
  ops: {
    editable: true,
    worktrees: true,
    branch: "main",
    node: null,
    role: "release"
  },
  olympus: {
    editable: true,
    worktrees: true,
    branch: "main",
    node: "22.21.1",
    role: "internal-tools"
  },
  odin: {
    editable: true,
    worktrees: true,
    branch: "main",
    node: "20.19.0",
    role: "service"
  },
  dinah: {
    editable: false,
    worktrees: false,
    branch: "main",
    node: "22.21.1",
    role: "legacy-source"
  }
};

const repo = process.argv[2];

if (!repo || !(repo in profiles)) {
  console.error("Usage: repo-profile <repo>");
  process.exit(1);
}

console.log(JSON.stringify({ repo, ...profiles[repo] }, null, 2));
