# Shared OpenCode Instructions

- This control plane supports multiple repositories that form one product.
- Use repo-specific worktrees for implementation and keep sessions scoped to one repo worktree whenever possible.
- Treat the control plane as a shared policy and tooling surface, not the main coding location.
- Keep cross-repo orchestration concise. Pass only the smallest necessary context between sessions.
- When the user mentions an `ENG-<id>` task and the Linear issue details are not already present in the conversation, fetch that Linear issue before repo investigation, worktree setup, or implementation.
- Treat repo hints such as "in odin" as routing hints only; use Linear as the task source of truth for title, description, acceptance criteria, labels, priority, status, links, and comments.
- If Linear is unavailable or the issue cannot be found, state that blocker before falling back to repo-only investigation.
- When output includes a URL, format it as a Markdown link (`[label](https://example.com)`) so it is clickable, unless the URL is inside a raw command output block or code block.
- Use one editing agent per repo worktree. Do not let multiple agents edit the same repo at once.
- Prefer stable scripts and tools under `bin/` and `.opencode/tools/` over ad hoc shell commands.
- Run simple diagnostics as separate commands or through project helpers. Avoid chaining commands with `&&`, `;`, or pipes when separate commands keep permissions automatic and output clearer.
- Prefer fast script-backed slash commands for deterministic control-plane work; reserve subagents for repo discovery, implementation, validation, migration audits, and cross-repo coordination.
- Use scoped OpenCode profiles to keep default context small:
  - `engineering`: shared engineering rules only
  - `migration`: engineering plus migration rules

## Agent Output Discipline

- Default to the shortest answer that preserves the decision, evidence, and next action.
- Put the conclusion first, then include only the evidence needed to trust it.
- Use at most three short headings in a final answer unless the user asks for a full report, audit, or plan.
- Prefer one compact paragraph plus bullets only when listing concrete files, commands, findings, or next steps.
- Omit sections that only restate the prompt, narrate process, or list expected negative findings.
- Include "not found" findings only when they change the diagnosis, block the work, or contradict the user's assumption.
- Collapse speculation into one ranked sentence when evidence is incomplete; do not list every possible cause.
- Do not end with optional offers such as "If you want, I can..." unless the user explicitly asks for options.
- For Datadog, Linear, GitHub, and command investigations, summarize the query or command scope and the actionable result; do not paste raw logs unless the raw line is the evidence.

## Datadog Investigation

- Use `datadog-investigator` for production or staging errors, latency, failed jobs, webhooks, queues, deploy regressions, traces, logs, and concrete runtime identifiers.
- Use Datadog for errors, incidents, traces, latency, failed jobs, webhooks, queues, deploy regressions, and prompts that include identifiers such as `trace_id`, `request_id`, `user_id`, `shipment_id`, `order_id`, or `payment_id`.
- Start with the narrowest useful time window, usually 15-60 minutes unless the user provides a time range.
- Filter by `env` and likely `service` when known, search logs for concrete identifiers or error messages, then inspect related traces or spans.
- Return query/time-range summaries, relevant counts, likely cause, and links. Do not paste secrets, tokens, or unnecessary PII from logs.
