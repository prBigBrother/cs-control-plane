#!/usr/bin/env node

import path from "node:path"

const [repo, engId, slug] = process.argv.slice(2)

if (!repo || !engId || !slug) {
  console.error("Usage: worktree-map <repo> <eng-id> <slug>")
  process.exit(1)
}

const editableRepos = new Set(["icarus", "daedalus", "ops", "olympus", "odin"])
const editable = editableRepos.has(repo)
const worktreePath = path.join("worktrees", repo, `${engId}-${slug}`)

console.log(JSON.stringify({ repo, engId, slug, editable, path: worktreePath }, null, 2))
