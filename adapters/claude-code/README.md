# Keel Adapter — Claude Code

This adapter maps Keel's tool-agnostic methodology (`../../core/`) onto concrete Claude Code mechanics: subagents (the Agent tool), the Workflow tool, the Skill tool, auto-memory files + `MEMORY.md`, and hooks in `settings.json`.

> Keel core is deliberately tool-agnostic. Wherever core says *"an independent reviewer in a fresh context"* or *"fan out parallel reviewers"*, this adapter tells you the literal Claude Code move.

---

## Install

From your project root (the repo where Claude Code runs):

| Step | Action |
|---|---|
| 1 | Copy `CLAUDE.md.tmpl` → `<repo>/CLAUDE.md`, fill the `{{PLACEHOLDERS}}`. |
| 2 | Create the Keel doc funnel (see `../../core/` and `../../templates/`): `docs/PROJECT_RULES.md`, `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/NEXT-STEPS.md`, `docs/PRD.md`. |
| 3 | Copy `memory/MEMORY.md.tmpl` → your Claude Code auto-memory dir as `MEMORY.md`, then drop in the seed memories from `memory/_SEED_MEMORIES.md` (one file each). |
| 4 | Merge `hooks/settings.snippet.json` into `<repo>/.claude/settings.json` (see `hooks/README.md`). |
| 5 | (Optional) Add a headless-browser driver under `scripts/` for ritual 6 live verification (see `rules/RITUALS-IN-CLAUDE-CODE.md`). |
| 6 | Tell the agent once: *"Honor the Keel rituals in `docs/PROJECT_RULES.md`."* — `CLAUDE.md` makes this stick. |

Auto-memory lives outside the repo (per-project, persists across sessions). Everything else is committed with the project.

---

## Ritual → Claude Code mechanism

Canonical ritual definitions: [`../../core/02-RITUALS.md`](../../core/02-RITUALS.md). Concrete playbooks: [`rules/RITUALS-IN-CLAUDE-CODE.md`](rules/RITUALS-IN-CLAUDE-CODE.md).

| # | Ritual (core) | Claude Code mechanism |
|---|---|---|
| 1 | Completion / pre-clear audit | Spawn **fresh Agent-tool subagents** as auditors, one per round; ≥3 rounds, exit on 2 consecutive clean (1st uncounted; earliest stop round 3) before any "done"/`/clear`. Each round = new context, no memory of prior verdicts. |
| 5 | Coherence pass per artifact | One **self-review subagent** after each spec/plan/design — drift, backward-compat, no placeholders, cross-artifact, docs-currency. |
| 6 | Live render/verify | **Headless-browser driver scripts** under `scripts/` (CDP / Playwright). Boot the stack, drive a real turn, screenshot, query the datastore. No "looks right" without a captured artifact. |
| 7 | Test-effectiveness audit | Subagent mutates code or asserts a known regression would be caught; "N passed" is not proof. |
| 8 | Review gate (assistant-owned) | **Subagent-driven** artifact production + the **Workflow tool** for decomposable fan-out (judge panels, adversarial verify, loop-until-converged). Min 3 iterations, exit on 2 consecutive clean. |
| 9 | Context budget & handoff | Keep the durable handoff (`docs/NEXT-STEPS.md` cursor + auto-memory) always current so `/clear` is safe anytime. Agent has no self-meter; rely on the human + handoff currency. |
| 10 | State-change currency | **PostToolUse hook** on `git push`/`merge` injects a reconcile reminder; agent updates front-door docs + auto-memory. |
| 11 | Dependency / vendor review | Subagent reviews what surfaced about off-limits or vendored components; append to the project's enhancements log. |
| 12 | Lessons-learned | At session end, append to `docs/lessons-learned/`; the **SessionEnd hook** stub reminds + snapshots durable notes. |
| 13 | Parallel-agent sync | Read-only parallel explore = many subagents. Parallel **impl** only on disjoint files. Rituals + doc/memory writes = single-writer, serial. |
| 14 | Doc model & anti-drift | The funnel `BACKLOG → ROADMAP → NEXT-STEPS → PRD`; stable IDs, one canonical home per item. Enforced by the coherence pass (ritual 5). |

> Rituals 2 (verification-driven), 3 (proactive-but-cautious), and 4 (don't hand-curate tool-owned state) have no distinct Claude Code mechanism — they live in the `CLAUDE.md` defaults and the seed memories:
> - Ritual 2 → `feedback_evidence_over_claims` seed memory + the "Evidence over claims" default in `CLAUDE.md.tmpl`.
> - Ritual 3 → `feedback_proactive_but_cautious` seed memory + the "Proactive but cautious" default in `CLAUDE.md.tmpl`.
> - Ritual 4 → `feedback_tool_owned_state` seed memory + the "ignore the planning tool's state dir; commit docs at milestones" default in `CLAUDE.md.tmpl`.
>
> See `CLAUDE.md.tmpl` and `memory/_SEED_MEMORIES.md`.

---

## When to use which mechanism

| You need… | Use |
|---|---|
| A gated chain (each step depends on the last) | Sequential **subagents** (Agent tool), one per step. |
| Decomposable fan-out (judge panel, adversarial verify, loop-until-converged) | The **Workflow tool**. |
| A reusable, named procedure invoked on demand | A **Skill**. |
| A fresh-context audit that must not see prior verdicts | A **new subagent** per round. |
| A trivial change | Inline — no subagent, no ceremony. |

Always name the choice; do not silently default to inline.

> Running a **gate itself** (or the execute phase) as a parallel **swarm** while keeping it
> strictly gated — the Orchestrator/Worker split, the "one round = N reviewers → one
> conservative verdict" collapse, race-free funnel writes, and Workflow-tool recipes — is in
> [`rules/GATED-SWARM.md`](rules/GATED-SWARM.md). Fan out the *work*, never the *gate*.

---

## Layout

```
adapters/claude-code/
  README.md                       ← this file
  CLAUDE.md.tmpl                  ← project CLAUDE.md skeleton
  rules/RITUALS-IN-CLAUDE-CODE.md ← per-ritual CC playbook
  rules/GATED-SWARM.md            ← run the gates as parallel fan-out without weakening them
  memory/MEMORY.md.tmpl           ← auto-memory index template
  memory/_SEED_MEMORIES.md        ← generalized seed memory bundle
  hooks/settings.snippet.json     ← hook config to merge
  hooks/README.md                 ← hook explainer + merge steps
  scripts/README.md               ← placeholder: the ritual-6 driver lives in YOUR project's scripts/, not here
```
