# Lifecycle — the loop every change runs through

> The proven loop a project runs *every* change through, with a review gate at
> each stage and a completion ritual before any seal or context reset. This is
> tool-agnostic: the stages and gates read the same whether the work is done by
> an AI coding agent, a fan-out of agents, or a human team.

See also: [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) (the cadence the gates use) ·
[`02-RITUALS.md`](02-RITUALS.md) (Rituals 9–10: durable cross-session handoff) ·
[`01-DOC-MODEL.md`](01-DOC-MODEL.md) (the resume cursor) ·
[`00-PHILOSOPHY.md`](00-PHILOSOPHY.md) (the values underneath).

---

## 1. Establish the GREEN BASELINE first

Before touching anything, prove the starting point is sound. You cannot tell
what *your* change broke if the tree was already broken.

A green baseline means, from a clean checkout:

- The working tree is clean (no stray uncommitted state).
- The documented build / boot / run commands actually work **from a clean
  state** — not against a leftover process or inherited environment. Kill stray
  background processes first, then boot fresh and confirm the environment loads.
- The test suite passes, and you have **looked at** the pass — counts and
  surfaces, not just an exit code.
- The "start here" / resume pointers route you to the *current* state of the
  project, not a finished milestone.

> Capture the baseline's numbers (test counts, the boot command, the current
> cursor) as the reference you will diff your change against. If you cannot get
> green from a clean state, fixing that **is** the first change — do it through
> the loop before starting the intended work.

---

## 2. The proven loop

Every change flows through six stages. Each stage produces something the next
stage consumes, and each gets a review gate sized to its leverage.

```
   ┌─────────────────────────────────────────────────────────────┐
   │                     GREEN BASELINE                           │
   │              (prove it before you start)                     │
   └─────────────────────────────────────────────────────────────┘
                              │
                              ▼
   ┌────────────┐   ┌────────┐   ┌────────┐   ┌─────────┐   ┌────────┐   ┌──────┐
   │ BRAINSTORM │──▶│  SPEC  │──▶│  PLAN  │──▶│ EXECUTE │──▶│ VERIFY │──▶│ SEAL │
   │  / DESIGN  │   │        │   │        │   │         │   │        │   │      │
   └─────┬──────┘   └───┬────┘   └───┬────┘   └────┬────┘   └───┬────┘   └──┬───┘
         │ light        │ FULL       │ FULL        │ light      │ evidence  │
         │ gate         │ cadence    │ cadence     │ gate       │ gate      │
         ▼              ▼            ▼             ▼            ▼           ▼
        (the review gate runs at every stage — §3)               ┌─────────────────┐
                                                                 │ COMPLETION       │
   on any FAIL: fix inline → re-run that stage's gate            │ RITUAL before    │
   convergence = approval → proceed automatically               │ every seal/reset │
                                                                 └─────────────────┘
                              │
                              ▼   (after seal: reconcile the hand-off, then the
                                   next change re-enters at BRAINSTORM)
```

| Stage | What it produces | Gate it gets |
|---|---|---|
| **Brainstorm / design** | The shape of the solution; resolved forks; the in-conversation design. | **Light gate** — one coherence pass *before* it is surfaced to the owner. The design counts as an artifact even before it is a written file. |
| **Spec** | The written design doc: what will be built and why, with acceptance. | **Full cadence** — min 3, exit on 2 consecutive clean ([`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §2). |
| **Plan** | The implementation plan: ordered tasks, each verifiable, no placeholders. | **Full cadence.** Every spec requirement must map to a plan task. |
| **Execute** | The actual change — built against the plan, tests derived from claims. | **Full cadence** on the execution-approach decision (how the plan is carried out — see [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §4), then a **light gate** per unit of work; behavioral verification as you go. |
| **Verify** | Evidence the change works at its real surface (tests, live render, queried state). | **Evidence gate** — show the result, analyze the *actual* output, not the intended one. |
| **Seal** | The change merged / shipped / closed, with the hand-off reconciled. | **Completion ritual** — the full heavy gate (§4). |

### Convergence is approval — proceed automatically

When a stage's gate **converges** (the cadence's exit condition is met), the
artifact is **approved by default**. Proceed immediately to the next stage and
surface the artifact for asynchronous reading — do **not** stop to ask "does
this look right, shall I continue?" Asking for that go-ahead on an
already-converged artifact defeats the gate.

The owner retains go/no-go only on **genuine decision points** the project
reserves — merges, pushes, which milestone to pursue, and gray-area design forks
surfaced explicitly. Those are real choices; a converged artifact's *review* is
not one of them.

The loop is automated **end to end**: once one artifact converges, immediately
produce the next (design → spec → plan → execute) and run its gate — without
stopping, including not stopping to propose a context reset. Keeping the work in
fresh, off-loaded contexts (see [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §6)
keeps the main thread light, so there is no "heavy seam" that justifies a pause.

---

## 3. The review gate at each stage

The gate machinery is one mechanism applied at two scopes (defined fully in
[`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §4):

- **Light gate** — one genuine coherence pass, inline, by the author, on the
  artifact just produced, *before* it moves on or is surfaced. This is the
  early-catch net: the author reviews their own artifact — the author *is* the
  first reviewer. Never surface what has not passed its own light pass, and state
  what the pass checked and found.
- **Heavy gate / full cadence** — the multi-round, fresh-context ritual reserved
  for the high-leverage artifacts (spec, plan, execution-approach) and for the
  seal.

Light gates feed the heavy gate: if every stage catches its own defects, the
completion ritual is confirmation, not discovery.

---

## 4. The completion ritual — before any seal or context reset

Before sealing a change (merge, ship, close) **or** before resetting / handing
off the working context, run the **full heavy gate** ([`03-REVIEW-GATES.md`](03-REVIEW-GATES.md)):
min 3 rounds, exit on 2 consecutive clean, each round an independent
fresh-context audit.

**Every reset gets the full ritual — routine seam or milestone alike. No tiers,
no exceptions.** The fresh-context reviewer is the truest test of whether the
*written* hand-off is resume-ready, which is exactly what a reset depends on.

The ritual's lenses, each round (vary the emphasis — [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §5):

| Lens | Checks |
|---|---|
| **Durable-notes coherence** | Cross-session notes agree; no stale "current work" markers. |
| **Front-door currency** | The entry-point docs and "start here" pointers route a fresh reader to the *current* stage, not a shipped one. |
| **Hand-off completeness** | Operational prereqs covered (services up, env present, deps installed, tests verified); cited revisions match reality (prefer "run the log command" over pinning a hash that drifts). |
| **Repo state** | Clean tree, tests green, only the expected untracked files. |
| **Test effectiveness** | The suite would actually catch a real regression — not vacuous, over-mocked, or tautological; risk paths covered or gaps named. "N passed" is not proof of quality on its own. |
| **Operational sanity** | The documented run/boot commands work from a clean state. |
| **Design-vs-reality drift** | No locked decision the code now contradicts (documented overrides are fine; silent contradictions are not). |
| **Commit narrative** | A stranger reading the commit log understands the path taken. |

The ritual is satisfied only when **≥3 rounds have run AND the last two are
consecutive clean** (the first round is groundwork and does not count toward
exit). Report each
round's findings transparently, then claim ready. An outer "are you sure?" is a
spot-check that the rounds happened — never the trigger for them.

---

## 5. Resume-safe hand-off

A change is not really done until the next reader can pick up cold. Keel treats
the hand-off as a first-class output of the loop, kept **always current** so a
context reset is safe at *any* moment.

- Update the durable cross-session notes and the **current cursor** ("where we
  are, what's next") at every atomic-unit boundary — not only at the seal.
- Right after any state-changing action (a push, a merge, a seal, a deferral, a
  branch cut), **reconcile the front-door docs and durable notes** for anything
  the change just made stale, then refresh any mirrored snapshot. Prefer
  drift-proof phrasing ("run the count command") over hardcoded facts that
  re-stale on the next change.
- Leave history alone — dated artifacts (archives, past specs/plans, "why" notes)
  describe past state and stay as written. Only *living* front-door docs and
  *current-state* notes get reconciled.
- When a session's lesson is **cross-cutting** (it will recur in sibling tasks),
  promote it from the dated lessons log into a standing **carry-forward
  checklist** referenced at the cursor, so the next reader inherits the warning
  rather than rediscovering it ([`02-RITUALS.md`](02-RITUALS.md) Ritual 12).

See [`02-RITUALS.md`](02-RITUALS.md) (Ritual 9 — context budget & resume-safe
handoff; Ritual 10 — state-change currency) for the hand-off contents and the
state-change-currency discipline in full, and [`01-DOC-MODEL.md`](01-DOC-MODEL.md)
for the resume cursor.

### The paste-ready resume prompt

Keep a single, copy-pasteable **resume prompt** in the front-door runbook — the
block a fresh reader (a new agent session or a new person) pastes to start
exactly where the last one stopped. A good resume prompt is self-contained:

- **Goal** — what the current initiative is trying to achieve, in one sentence.
- **Where we are** — the current state, including what is green and what is still
  manual / pending.
- **First read** — the ordered list of files to open, most authoritative first
  (the current cursor before anything else).
- **Locked decisions** — settled forks, so the reader does not relitigate them.
- **Constraints / people** — who owns which gated action; what the reader cannot
  do alone.
- **First step** — the literal next action.

Because the prompt is pasted into a *fresh* context, it must stand alone — assume
the reader has no memory of the conversation that produced it. Keeping it current
is part of the hand-off discipline above; the completion ritual's
front-door-currency lens verifies it routes to the *current* stage.

---

## 6. Guardrails

Standing constraints that ride along the whole loop, regardless of stage:

| Guardrail | Rule |
|---|---|
| **Evidence over claims** | Never assert "done / fixed / passing / in sync" without running and *showing* the verification first, in the same breath. |
| **Behavioral verification** | Verify at the real user-/system-facing surface. For anything with a visible or behavioral surface, render and check it live before claiming it works — don't claim from code-reading alone. Pure-internal changes verify by tests / queried state. |
| **Don't break the foundation** | The green baseline is sacred; a change that regresses it is not done, however complete the feature looks. |
| **Quick where safe, cautious where costly** | Read / inspect / build / test freely; trace the effect of every command before running it; confirm destructive or hard-to-reverse operations. |
| **Provision before you reference** | Every *referenced* resource exists before the reference is evaluated. Treat an aggregated secret/config bundle as **all-or-nothing** — one missing key fails the whole unit and every consumer of it. Inject each value into the component that actually **consumes** it and confirm the consumer reads it. Keep a migration/bootstrap entrypoint depending on the **minimum** it needs, not the whole app config, so it can run before the full surface is provisioned. Provisioning order is hardening, not an afterthought. |
| **Don't hand-curate tool-owned state** | Files a tool owns and regenerates (any tool-owned state directory) are not the hand-off — put the durable record where *you* own it (the docs, the plan, the commit log, the durable notes). |
| **One canonical home per fact** | Each decision/item lives in exactly one authoritative doc; everything else references it. Stable IDs, never reused, so cross-references survive edits. |
| **Hand-off stays current** | The cursor + durable notes are refreshed at every atomic-unit boundary so a reset is always safe. |

---

## 7. Quick reference

```
BASELINE   prove green from a clean state BEFORE touching anything
LOOP       brainstorm → spec → plan → execute → verify → seal
GATES      brainstorm = light · spec/plan/exec-approach = FULL cadence
           execute = light per unit · verify = evidence · seal = ritual
APPROVAL   convergence = approval → proceed automatically (no "shall I?")
RITUAL     before EVERY seal/reset: full heavy gate, fresh-context, no tiers
HANDOFF    cursor + notes current at every boundary; reconcile after state changes
RESUME     keep one self-contained paste-ready resume prompt in the runbook
```
