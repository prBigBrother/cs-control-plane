# Migration Instructions

- Daedalus is the target system. Dinah is legacy and should not receive new product expansion.
- `dinah` is a legacy source repo and is read-only in this control plane.
- Include `dinah` in migration audits, dependency tracing, and cutover analysis.
- Do not create editable worktrees for `dinah`.
- Migrations should follow two explicit phases:
  - Phase 1: dual write plus flagged rollout
  - Phase 2: cutoff plus cleanup
- Phase 1 should dual-write from Daedalus without adding new Dinah application logic.
- Frontend rollout should stay behind a flag until cutoff. In Icarus, new `FF_*` flags must be reflected in both `packages/icarus/.env.sample.staging` and `packages/icarus/scripts/env.template.js`.
- Migration notes should capture source-of-truth decisions, remaining legacy touchpoints, rollout dependencies, and any backfill or reconciliation path.
