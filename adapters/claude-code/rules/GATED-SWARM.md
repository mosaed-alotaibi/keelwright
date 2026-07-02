# Gated Swarm — running Keelwright's gates as parallel fan-out without weakening them

Keelwright's gates ([`../../../core/03-REVIEW-GATES.md`](../../../core/03-REVIEW-GATES.md)) and
lifecycle ([`../../../core/04-LIFECYCLE.md`](../../../core/04-LIFECYCLE.md)) read as a
*sequential* chain. They do **not** have to run sequentially. Core already says so —
`03-REVIEW-GATES.md §6`: *"You can **fan out** multiple fresh reviewers in parallel for
read-only audit rounds … then have a single owner apply the fixes between rounds."* This
file is the literal Claude Code "how": run the parallel work as a **swarm** (the Workflow
tool) while keeping every gate-bearing, single-writer step exactly as strict as before.

> The rule in one line: **fan out the *work*; never fan out the *gate*.** Parallelism buys
> breadth *inside* a round and *inside* execute. It must never buy speed by collapsing the
> round *sequence*, the consecutive-clean streak, the owner-veto funnel, or the doc writes.

See also: [`RITUALS-IN-CLAUDE-CODE.md`](RITUALS-IN-CLAUDE-CODE.md) (Rituals 1, 8, 13) ·
[`../README.md`](../README.md) ("when to use which mechanism").

---

## 1. Two roles: Orchestrator and Workers

| Role | Count | Owns | May it write? |
|---|---|---|---|
| **Orchestrator** | exactly one (the main thread) | All *sequential* state: the clean-streak counter, the `NEXT-STEPS` cursor, stable-ID allocation, the convergence verdict, and every gated action (merge/push/seal). | Yes — it is the single writer for rituals, the doc funnel, and memory. |
| **Worker** | many (swarm) | Nothing durable. Each is either a **read-only, verdict-blind auditor** in fresh context, or a **disjoint-file implementer**. | Only a disjoint file set it was handed; never a shared hub, never the funnel, never the streak. |

This is Ritual 13 made literal: read-only explore = unlimited fan-out; parallel implement =
disjoint files only; rituals + doc/memory writes = single-writer through the Orchestrator.

---

## 2. The invariant table — what fans out vs what stays a barrier

| Stays a SEQUENTIAL barrier (Orchestrator only) | Safely FANS OUT to a swarm |
|---|---|
| The **round sequence** — round N+1 starts only after round N's verdict + any fix. | The **N reviewers inside one round** (each a distinct lens, fresh context). |
| The **clean-streak** counter and the EXIT decision. | **Research / codebase-mapping / precedent-mining** (read-only). |
| **Fix application** between rounds (single-writer). | **Disjoint implementation tasks** (one writer per file set). |
| The **spec → plan → execute** ordering (each consumes the approved prior). | **Authoring inputs** for a spec/plan; independent **surface checks** at verify. |
| **Doc-funnel writes** + `MEMORY.md` index + ID allocation. | Per-component first-draft *content* (later merged by the one writer). |
| **Owner-veto** actions: merge, push, release, milestone choice, gray-area forks. | — (never delegated) |

---

## 3. A review round with N reviewers → ONE verdict

A **round** is still *one adversarial pass* (`03-REVIEW-GATES.md §1`). Implementing it as a
swarm does not make N reviewers into N rounds — it makes one round *broader*:

```
round(k):
  fan out N fresh-context, verdict-BLIND auditors in parallel (one Workflow phase),
    each assigned a DISTINCT lens:
      - drift / citations-vs-LIVE-code
      - backward-compat / every call site
      - cross-artifact consistency + every requirement → a task
      - docs & memory currency / front-door pointers
  barrier-join, then COLLAPSE by SEVERITY (the Orchestrator owns this call):
      each finding is BLOCKER | MAJOR | MINOR.
      FAIL   if any worker found a BLOCKER/MAJOR (something that *needs* changing)
             → fix single-writer, reset the streak.
      CLEAN  if no blocker/major remains. MINOR nits are *dispositioned* by the
             Orchestrator (accept / defer to BACKLOG / fold in) and do NOT, by
             themselves, reset the streak.
  → the Orchestrator records ONE verdict for round k.
```

Each worker must re-verify citations against **live code this round**, **tag each finding's
severity**, and state its lens coverage — a bare "looks good" is not a round (`§1`, `§6`).
Breadth within a round is *not* depth over time: the floor of 3 still applies across rounds,
and the two-*consecutive*-clean exit holds through round 5 (the round-6 relief valve is the
only relaxation — see the pseudocode below).

> **Convergence pitfall (learned in the field).** Do **not** define CLEAN as "zero findings
> of any kind" — adversarial reviewers *always* surface a minor nit, so the streak never
> reaches two-consecutive and the gate loops forever (burning tokens). CLEAN = **no
> blocker/major left**; the Orchestrator dispositions minors and **owns the final verdict**.
> If the blocker/major count is trending to zero but minors keep the streak from closing,
> that is the Orchestrator's signal to disposition the minors and call convergence — not to
> spin another round.

> **Reconciliation with core's findings ledger.** An undisposed minor is still an `open`
> finding in the [`03-REVIEW-GATES.md`](../../../core/03-REVIEW-GATES.md) *findings ledger*;
> the Orchestrator's disposition (accept / defer to BACKLOG / fold in) moves it to `fixed` /
> `wontfix`, so the round is CLEAN by core's "no **new open** finding" rule. The severity cut
> here is the Orchestrator's *disposition heuristic*, not a second definition of CLEAN —
> blocker/major ⇒ a fix is required (reset the streak); minor ⇒ disposition it into the ledger.
> Same gate, one CLEAN.

### Preserving the consecutive-clean streak

The Orchestrator runs rounds **strictly ordered** and holds the only counter:

```
streak = 0
for k = 1, 2, 3, …:
    verdict = round(k)              # the parallel batch above
    if k == 1: continue            # round 1 is groundwork — uncounted
    if verdict == CLEAN: streak += 1
    else: streak = 0; apply fixes (single-writer); # next round runs vs post-fix state
    if k >= 3 and streak >= 2: EXIT  # floor met AND last two consecutive clean
    if k >= 6 and verdict == CLEAN: EXIT  # relief valve — one clean exits from round 6 on
```

A FAIL always resets the streak; through round 5 a clean round after a fail never exits.
From round 6 onward the relief valve opens (core `03-REVIEW-GATES.md` §2 (rule 5)): any single clean
round converges — a FAIL at 6+ still needs one subsequent clean. Workers never see
the streak or prior verdicts — that is what keeps each round honestly adversarial.

---

## 4. Per-phase mapping (the lifecycle as a gated swarm)

| Phase | Sequential barrier (Orchestrator) | Fans out (swarm) |
|---|---|---|
| **Brainstorm / design** | 1 light coherence pass before surfacing. | Research, codebase mapping, precedent mining (read-only). |
| **Spec** | Full cadence; the verdict per round. | Each round's audit (§3); authoring inputs + current-state verification. |
| **Plan** | Full cadence; requirement→task completeness is one writer's matrix. | Each round's audit; authoring inputs. |
| **Execute** | Execution-approach decision = full cadence (owner-veto if a genuine fork). | Then disjoint plan tasks → implementer swarm, each with its own light gate + live behavioral verification. |
| **Verify** | Evidence gate — the Orchestrator analyzes the *actual* output. | Independent surface checks (tests / live render / queried state). |
| **Seal** | Completion ritual = full heavy gate, no tiers; merge/push = owner-veto. | Within-round audits across fresh reviewers (the 8 lenses of `04-LIFECYCLE §4`). |

---

## 5. Concrete Workflow recipes

The Workflow tool runs a script that fans out `agent()` calls. The two shapes:

**(a) One review round = a parallel reviewer panel that collapses to one verdict.**

```js
// inside a workflow script — ONE round over an artifact
const LENSES = ['drift+citations', 'backward-compat+call-sites', 'cross-artifact+req→task', 'docs+memory-currency']
const reviews = await parallel(LENSES.map(lens => () =>
  agent(`Adversarially audit <artifact> through the ${lens} lens ONLY. Re-verify every cited
          path/line/symbol against LIVE code this pass. Return {clean:boolean, findings:[...]}.`,
        { label: `round:${lens}`, schema: VERDICT })))
const clean = reviews.filter(Boolean).every(r => r.clean)        // CONSERVATIVE collapse
return { clean, findings: reviews.flatMap(r => r?.findings ?? []) }
```

The **Orchestrator** (main thread) calls this once per round, owns the streak, applies fixes
between rounds, and decides EXIT. Do **not** put the streak loop inside the workers.

**(b) Execute = disjoint-file implementer swarm (pipeline), each unit self-light-gated.**

```js
// each task touches a disjoint file set; isolation:'worktree' only if they'd collide
await pipeline(TASKS,
  t => agent(`Implement ${t.id} (files: ${t.files}). Then run its light gate + behavioral
              check; return evidence.`, { label: t.id, schema: UNIT }),
  unit => agent(`Adversarially verify ${unit.id}'s evidence is real (not asserted).`,
                { label: `verify:${unit.id}`, schema: VERDICT }))
```

**(c) Loop-until-converged** = the Orchestrator repeats recipe (a) until
`(streak >= 2 && k >= 3) || (k >= 6 && verdict == CLEAN)` — the pair exit, or the round-6
relief valve. Keep the loop in the *orchestrator*, not the workflow, so the gate stays
single-owned.

> Cost note: a round is N parallel reads — cheap and fast. The expense is depth (rounds over
> time), which is exactly the thing the cadence *requires*. The swarm removes the wall-clock
> cost of breadth, not the discipline of depth.

---

## 6. Race-free doc funnel under parallelism

`BACKLOG → ROADMAP → NEXT-STEPS → PRD` writes are single-writer (Ritual 13/14). Under fan-out:

- **One doc-writer.** All durable writes route through the Orchestrator (or one delegated
  doc-writer subagent). Workers *return content*; they never write the funnel.
- **Cursor is a singleton.** `NEXT-STEPS.md` is updated by one writer at unit boundaries.
- **Centralized ID allocation.** Workers *request* the next stable ID; they never self-pick
  (two pickers would collide). One canonical home per fact means workers reference by ID and
  never restate — so disjoint per-component edits cannot clash.
- **Seal is one atomic transaction.** The ROADMAP/PRD/BACKLOG status flip at ship is one
  writer, one commit.
- **One drift-sweeper.** The state-change-currency reconcile (Ritual 10) is a single actor.

---

## 7. Quick reference

```
ROLES      Orchestrator (1, owns streak/cursor/IDs/seal) + Workers (stateless: read-only
           verdict-blind auditors OR disjoint-file implementers)
ROUND      = ONE parallel reviewer panel → collapse CONSERVATIVE (CLEAN iff all clean)
SEQUENCE   rounds strictly ordered vs post-fix state; streak lives only in the Orchestrator
EXIT       floor ≥3 AND last two rounds consecutive clean (round 1 groundwork)
RELIEF     from round 6 onward, ONE clean round exits (a FAIL at 6+ needs a subsequent clean)
FAN OUT    research · within-round audits · disjoint impl · surface checks
NEVER FAN  the streak · the verdict · fix application · funnel/memory writes · owner-veto
EVIDENCE   the Orchestrator re-shows same-turn behavioral proof for the whole; worker
           "done" summaries do NOT satisfy the claim gate
```
