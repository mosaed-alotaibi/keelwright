# Rituals in Claude Code — concrete playbooks

The Keelwright rituals are defined tool-agnostically in [`../../../core/02-RITUALS.md`](../../../core/02-RITUALS.md). This file is the literal Claude Code "how" for each. Where core says *"an independent reviewer in a fresh context"*, here it means **a new subagent spawned via the Agent tool**. Where it says *"fan out parallel reviewers"*, it means **the Workflow tool** (or several Agent-tool subagents).

> **Why the numbering jumps 1 → 5:** rituals 2 (verification-driven), 3 (proactive-but-cautious), and 4 (don't hand-curate tool-owned state) have no distinct Claude Code mechanism — they live in the `CLAUDE.md` defaults + the seed memories (`feedback_evidence_over_claims`, `feedback_proactive_but_cautious`, `feedback_tool_owned_state`), not as a subagent/hook playbook. See [`../README.md`](../README.md) and `../memory/_SEED_MEMORIES.md`.

---

## Ritual 1 — Completion / pre-clear audit

**Goal:** ≥2 *consecutive* clean audit rounds before any "we're done" milestone or `/clear`.

Playbook:
1. Spawn a **fresh Agent-tool subagent** as auditor. Give it the artifacts + the acceptance criteria; do **not** tell it prior verdicts.
2. The subagent genuinely re-audits — drift, gaps, broken claims, leakage — and returns findings.
3. If findings → fix → start the count over. If clean → that's round *N* clean.
4. Repeat with a **new** subagent each round (fresh context, no rubber-stamping). Exit only on 2 consecutive clean.
5. For breadth, run ≥3 subagent rounds across the surface; a single pass is not an audit.

> The 1st pass is foundational and uncounted — it establishes the baseline. Count clean rounds *after* it.

> **Swarm form:** a single round may **fan out** N verdict-blind auditors (each a distinct lens) in parallel and collapse to ONE conservative verdict (CLEAN iff *all* clean). Rounds still run strictly in sequence against post-fix state, and the streak lives only in the orchestrator — breadth inside a round is not depth over time. See [`GATED-SWARM.md`](GATED-SWARM.md) §3.

---

## Ritual 5 — Coherence pass per artifact

**Goal:** one genuine coherence pass after each spec / plan / design, before moving on.

Playbook:
- Spawn **one** subagent (or do it inline if small) checking: drift from intent, backward-compat, no placeholders left, cross-artifact consistency (does the PRD match the ROADMAP?), docs-currency.
- This is the light early-catch gate that feeds the heavier ritual-1 count. Don't skip it just because ritual 1 exists.

---

## Ritual 6 — Live render / verify

**Goal:** never claim a UI/behavioral surface works without a captured artifact. Pure-backend logic with deterministic tests is exempt; anything user-facing is not.

Playbook:
- Use a **headless-browser driver script** under your project `scripts/` — a CDP/Playwright-style "drive one real turn + screenshot" plus a "navigate to route + screenshot" helper. Keelwright does not ship one (stacks vary); add a thin driver for `{{WEB_FRAMEWORK}}` (see README install step 5).
- Boot the stack, drive a real interaction, capture the screenshot, and where state matters, query the datastore to confirm the write.
- Attach/point to the captured artifact in your claim. "Looks right" is not evidence.
- For functional vs. design sign-off: passing the functional gate is **not** design approval — show the screenshot and get the owner's look-approval before sealing UI.

---

## Ritual 7 — Test-effectiveness audit

**Goal:** confirm tests would actually catch a real regression — "N passed" ≠ quality.

Playbook:
- Spawn a subagent to either inject a plausible bug and confirm a test goes red, or trace a known past regression to the test that now guards it.
- Run this on test-change and at seal. Cover all test types, not just unit.
- Derive tests from business/technical *claims* and verify behavior at the surface; don't over-test internals (connectivity, "row exists").

---

## Ritual 8 — Review gate (assistant-owned)

**Goal:** the assistant reviews its own spec / plan / execution-approach. Min 3 iterations; exit on 2 consecutive clean (1st pass foundational, uncounted). Execution is automated; the human delegates and spot-checks via ritual 1.

Playbook — pick the shape:

| Situation | Mechanism |
|---|---|
| Linear, each step depends on the last | Sequential **Agent-tool subagents**, one per step, each consuming the prior's output. |
| Decomposable fan-out — judge panel scoring one artifact, adversarial verify, loop-until-converged | The **Workflow tool**. |
| Producing the artifact itself | **Subagent-driven**: one subagent drafts, another critiques, you reconcile. |

Loop-until-converged with the Workflow tool: define the artifact, the critique rubric, and the exit condition (2 consecutive clean). Let it iterate; you own the final verdict.

> Keep the streak loop in the **orchestrator** (the main thread), not inside the workflow: workers vote *within* a round; the orchestrator owns the round *sequence* and the EXIT. Concrete recipes + the per-phase barrier-vs-fan-out map: [`GATED-SWARM.md`](GATED-SWARM.md).

---

## Ritual 9 — Context budget & handoff

**Goal:** `/clear` is safe at any moment because the handoff is always current.

Playbook:
- The agent has **no self-meter** for context %. The human watches the CLI meter. Don't guess your own usage.
- Keep `docs/NEXT-STEPS.md` cursor + the relevant auto-memory current as you go, not at the end.
- Propose clear-and-resume at heavy seams (after a seal, before a big new initiative).

---

## Ritual 10 — State-change currency

**Goal:** after any state change (push / merge / seal / defer / branch), front-door docs + durable notes are reconciled — without being asked.

Playbook:
- The **PostToolUse hook** (`../hooks/settings.snippet.json`) fires on `git push`/`merge` and injects a reminder to run the reconcile.
- On that reminder: scan `docs/NEXT-STEPS.md`, `docs/ROADMAP.md`, and affected auto-memory for now-stale claims; update them with drift-proof phrasing. Leave history alone.

---

## Ritual 11 — Dependency / vendor review

**Goal:** before pre-clear each session, capture what surfaced about vendored or off-limits components.

> **Conditional** — applies only if you depend on a component you *can't change* (a vendored host, a third-party service, an upstream library). If you have no such dependency, skip it entirely.

Playbook:
- Spawn a subagent (or note inline) reviewing the session for findings about third-party / vendored hosts you can't modify.
- Append `NN`-numbered items to the project's enhancements log; work *around* off-limits code from your own layer, never edit it.

---

## Ritual 12 — Lessons-learned

**Goal:** durable issues / mitigations / lessons land before pre-clear.

Playbook:
- At session end, append concise **Issue / Mitigation / Lesson** entries to `docs/lessons-learned/`, grouped by area (auth, infra, deployment, tooling, local dev, …). One entry = three one-liners. "No notable issues" is a valid pass — don't manufacture entries.
- Use the format in [`../../../templates/docs/lessons-learned/`](../../../templates/docs/lessons-learned/) (`_ENTRY_TEMPLATE.md.tmpl` per session, indexed in `README.md.tmpl`).
- The **SessionEnd hook** stub reminds you and snapshots durable notes (see `../hooks/README.md`).

---

## Ritual 13 — Parallel-agent sync

**Goal:** parallelism without corruption.

Playbook:
- **Explore** read-only → fan out many subagents freely.
- **Implement** in parallel → only on *disjoint* files; never two writers on one path.
- **Rituals + doc/memory writes** → single-writer, serial. No worktrees over a shared hub for these.

> [`GATED-SWARM.md`](GATED-SWARM.md) §1–§2, §6 turns this taxonomy into an operating model: the Orchestrator is the single writer for the funnel/memory/streak; Workers are read-only auditors or disjoint-file implementers that *return* content and never touch a shared hub.

**Git hygiene when subagents leave a dirty tree.** Delegated subagents and verification steps can leave stray files in the working tree, so **stage explicitly** — name the files you mean to commit rather than blanket `git add -A`, which sweeps in their artifacts. Have verification/audit helpers write to a temp dir **outside the repo** so nothing lands in the tree to begin with. And **re-confirm staging after a mixed delete + edit**: a staged deletion does not pull in an unstaged sibling edit — check `git status` before committing.

---

## Ritual 14 — Doc model & anti-drift

**Goal:** the funnel stays coherent; no duplicated facts.

Playbook:
- `BACKLOG → ROADMAP → NEXT-STEPS → PRD`. Stable IDs; one canonical location per item, others reference by ID.
- The coherence pass (ritual 5) is the enforcement point — it checks cross-artifact consistency every time you touch a funnel doc.

---

## Ritual 15 — Housekeeping adjudication

**Goal:** an *agent-originated* destructive chore gets **one** bounded adversarial pass before it runs; the orchestrator decides; the owner is the only escalation.

> **Trigger is objective, not vibes.** Run the pass before the action if it does **any** of: deletes/force-overwrites a **tracked file or git ref** (branch/tag/remote); mutates **committed config** (`.gitignore`, `.claude/settings.json`, CI, infra manifests) or any version-controlled file **outside the current task's diff**; reaches **outside the task's worktree** (another branch/worktree, global git config); or **cannot be undone by a single inverse command you can write out in advance**. A chore tripping **none** of these — and **any** chore the **owner explicitly asked for** — is exempt: just do it.

Playbook:
1. Spawn **one** fresh Agent-tool subagent as an adversarial reviewer. Give it the exact action, the objective trigger(s) it tripped, and the one-line undo you intend (or "no clean undo" if there isn't one).
2. The subagent returns a **verdict + the single strongest counter-argument** — not a fix, not a second opinion to average.
3. **The orchestrator (main thread) decides** from that verdict. Proceed, adjust, or abandon the chore.
4. **One pass, then decide — never a second reviewer round.** Two no-authority reviewers only manufacture a consensus the orchestrator would override. If the single pass is genuinely inconclusive, **escalate to the owner**, not to another subagent.

> Why a *single* bounded pass: this is Principle 11 (*challenge — adversarially, and bound it*) applied to janitorial actions — enough rigor to catch a one-way mistake (a force-deleted ref, a clobbered shared config), bounded so the gate stays cheap and loop-free. Any fix the verdict produces still obeys single-writer discipline (ritual 13).

---

## Ritual 16 — Dependency-reality check

**Goal:** before designing or building against an unfamiliar / fast-moving / post-knowledge-cutoff dependency, confirm its **real** behavior against the installed artifact — not prose docs, not your priors.

Playbook:
- **Read/Grep the installed package, not the docs site.** Open the dependency's source + type definitions where they actually live on disk (`node_modules/<pkg>`, the site-packages dir, a vendored copy) plus the **lockfile** for the exact installed version. Confirm error/return semantics, the real export/import paths, which helper actually wraps the behavior you need, and the current CLI/API surface **for that version** — not an older or newer one.
- **Probe when the source is unclear.** If you can't confirm a behavior by reading, have a subagent (or a throwaway script) exercise it and report the *actual* result back — don't assume.
- **Pin the exact version** you verified against, and treat a fast release cadence as a standing patch obligation: re-check on upgrade.
- This is **disciplined design-time tool use, not orchestration** — no hook or special swarm is required (a subagent can do the read and hand you back the confirmed semantics). A dependency premise feeds the Ritual 5 coherence pass: when a design rests on "the dependency does X," cite **where** in the installed package you confirmed X.

> Designing from priors alone yields config that is plausible but wrong — exactly the class of defect the early gates exist to catch before the completion ritual.

---

## Skills

Wrap any ritual you run often as a **Skill** (e.g. a "run completion audit" skill that spawns the round-1 subagent with the right prompt). Skills make the procedure invokable on demand and keep the prompt consistent across sessions.
