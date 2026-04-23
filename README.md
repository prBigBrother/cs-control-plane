# Citizenshipper Control Plane

This repository is the shared OpenCode control plane for the Citizenshipper multi-repo product.

It owns:
- shared OpenCode config, instructions, commands, and agents
- submodule references to the product repositories
- worktree bootstrap and cleanup scripts
- shared memory and orchestration helpers

It does not own product code. Active edits should happen in repo-specific worktrees under `worktrees/`.

## Layout

```text
.
├── .opencode/
│   ├── agents/
│   ├── commands/
│   ├── plugins/
│   └── tools/
├── bin/
├── instructions/
├── repos/
└── worktrees/
```

## Operating Model

1. Keep the canonical base checkouts in `repos/` as git submodules.
2. Create per-task worktrees in `worktrees/<repo>/ENG-<id>-<slug>/`.
3. Open OpenCode directly in each worktree for implementation.
4. Use the control plane when you need shared commands, subagents, memory, or bootstrap scripts.
5. Use `./bin/install-local-opencode <path>` to attach the shared OpenCode config to any repo or worktree without committing personal config files.

## Bootstrap

Initialize submodules:

```bash
./bin/add-submodules
```

Create worktrees:

```bash
./bin/new-task icarus ENG-123 checkout-redesign feature
./bin/new-task daedalus ENG-123 checkout-redesign feature
```

Attach shared OpenCode config to a base repo or worktree:

```bash
./bin/install-local-opencode repos/icarus
./bin/install-local-opencode worktrees/icarus/ENG-123-checkout-redesign
```

Show repo profiles:

```bash
./bin/repo-profile icarus
./bin/repo-profile dinah
```

Map worktrees:

```bash
./bin/worktree-map icarus ENG-123 checkout-redesign
```

## OpenCode Session Model

- Implementation sessions should run inside a repo worktree.
- The control plane repo is for shared policy, orchestration, and maintenance.
- `dinah` participates in migration and audit workflows as read-only. It does not get editable worktrees.

## Memory

The control plane is prepared for a self-hosted Mem0 deployment.

- Copy `.env.example` to `.env` and fill the Mem0 values.
- The shared memory tooling only stores distilled decisions and runbook-level facts.
- Do not store secrets, raw code, or full diffs.
