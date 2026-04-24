#!/usr/bin/env node

import path from "node:path"
import fs from "node:fs"

const [repo, engId, slug] = process.argv.slice(2)

if (!repo || !engId) {
  console.error("Usage: worktree-map <repo> <eng-id> [slug]")
  process.exit(1)
}

const editableRepos = new Set(["icarus", "daedalus", "ops", "olympus", "odin"])
const editable = editableRepos.has(repo)
const worktreeRoot = path.join("worktrees", repo)
let resolvedSlug = slug

if (!resolvedSlug && fs.existsSync(worktreeRoot)) {
  const matches = fs
    .readdirSync(worktreeRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && entry.name.startsWith(`${engId}-`))
    .map((entry) => entry.name)
    .sort()

  if (matches.length === 1) {
    resolvedSlug = matches[0].slice(`${engId}-`.length)
  } else if (matches.length > 1) {
    console.error(`Error: multiple worktrees match ${repo} ${engId}; pass the slug explicitly.`)
    for (const match of matches) console.error(path.join(worktreeRoot, match))
    process.exit(2)
  }
}

const worktreePath = resolvedSlug
  ? path.join(worktreeRoot, `${engId}-${resolvedSlug}`)
  : path.join(worktreeRoot, `${engId}-<slug>`)

console.log(JSON.stringify({ repo, engId, slug: resolvedSlug || null, editable, path: worktreePath }, null, 2))
