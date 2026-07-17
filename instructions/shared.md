# Shared OpenCode Instructions

- This control plane supports multiple repositories that form one product.
- Use repo-specific worktrees for implementation and keep sessions scoped to one repo worktree whenever possible.
- Treat the control plane as a shared policy and tooling surface, not the main coding location.
- Keep cross-repo orchestration concise. Pass only the smallest necessary context between sessions.
- When the user mentions an `ENG-<id>` task and the Linear issue details are not already present in the conversation, fetch that Linear issue before repo investigation, worktree setup, or implementation.
- Treat repo hints such as "in odin" as routing hints only; use Linear as the task source of truth for title, description, acceptance criteria, labels, priority, status, links, and comments.
- If Linear is unavailable or the issue cannot be found, state that blocker before falling back to repo-only investigation.
- Use one editing agent per repo worktree. Do not let multiple agents edit the same repo at once.
- Prefer stable scripts and tools under `bin/` and `.opencode/tools/` over ad hoc shell commands.
- Run simple diagnostics as separate commands or through project helpers. Avoid chaining commands with `&&`, `;`, or pipes when separate commands keep permissions automatic and output clearer.
- Prefer fast script-backed slash commands for deterministic control-plane work; reserve subagents for repo discovery, implementation, validation, migration audits, and cross-repo coordination.
- Use scoped OpenCode profiles to keep default context small:
  - `engineering`: shared engineering rules only
  - `migration`: engineering plus migration rules

## Output Discipline

- Lead with the conclusion in a friendly, direct tone.
- Include only evidence needed to trust it and the next required action. Use short bullets for files, commands, findings, or status.
- Omit prompt restatement, process narration, routine negative findings, broad speculation, and raw logs. Quote a raw line only when it is essential evidence.
- Keep failures short: state what failed, why it matters, and the exact repair or next command.
- Use no more than three short headings unless a detailed report was requested.
- End when the work is clear. Do not add praise, generic summaries, or optional filler such as “If you want…”.
- Format URLs as descriptive Markdown links outside code blocks.

## Datadog Investigation

- Use `datadog-investigator` for production or staging errors, latency, failed jobs, webhooks, queues, deploy regressions, traces, logs, and concrete runtime identifiers.
- Use Datadog for errors, incidents, traces, latency, failed jobs, webhooks, queues, deploy regressions, and prompts that include identifiers such as `trace_id`, `request_id`, `user_id`, `shipment_id`, `order_id`, or `payment_id`.
- Start with the narrowest useful time window, usually 15-60 minutes unless the user provides a time range.
- Filter by `env` and likely `service` when known, search logs for concrete identifiers or error messages, then inspect related traces or spans.
- Return query/time-range summaries, relevant counts, likely cause, and links. Do not paste secrets, tokens, or unnecessary PII from logs.
