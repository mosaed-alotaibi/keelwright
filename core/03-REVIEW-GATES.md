# Review Gates — the convergence cadence

> The engine behind Keel's review rituals. This file defines *how* a piece of
> work is judged ready: not by one look, but by repeated adversarial passes that
> must run dry before you stop. It is tool-agnostic — the reviewer can be a
> separate agent session, a second AI, or a different person.

See also: [`00-PHILOSOPHY.md`](00-PHILOSOPHY.md) (the values these gates enforce) ·
[`04-LIFECYCLE.md`](04-LIFECYCLE.md) (where each gate attaches in the loop).

---

## 1. The unit: a round

A **round** (interchangeably, an **iteration**) is **one genuine adversarial
pass** over an artifact. A round has exactly two outcomes:

| Outcome | What it means | Effect on the streak |
|---|---|---|
| **FAIL** | The pass found something that needs changing. Fix it inline (or surface it for a decision), then continue. | Resets the clean streak to zero. |
| **CLEAN** | The pass found nothing needing change. | Adds one to the clean streak. |

A round is only real if it is **genuinely adversarial** — it tries to break the
artifact, not to bless it. A pass that asserts "looks good" without naming what
it checked is **not a round**. The *findings are the evidence the round ran*; a
round with no stated lens coverage does not count.

> A FAIL is not a failure of the process — it is the process working. The goal
> of a round is to *find* problems while they are cheap. Finding nothing is the
> exit condition, not the objective.

---

## 2. The cadence

The cadence governs when a sequence of rounds is allowed to stop.

1. **Floor — minimum 3 rounds.** Always run at least three, no matter what.
2. **The first round is groundwork.** It does **not** count toward the exit,
   even if clean — a groundwork pass regardless of outcome. You can never stop
   at two rounds.
3. **Exit — two CONSECUTIVE clean rounds**, *and* the floor of 3 is met. The
   earliest possible stop is round 3 (rounds 2 and 3 both clean).
4. **If not converged, continue in pairs.** A FAIL resets the streak. After
   fixing, you need two clean rounds *in a row* again. A single clean round
   after a fail never exits.

In one line: **stop only when the floor is met AND the last two rounds are both
clean.** A fix always resets the streak — clean rounds must be *consecutive*.

### Why these three numbers

| Rule | Reason |
|---|---|
| Floor of 3 | One pass catches the obvious; the floor forces depth past the obvious. |
| First round doesn't count | A single clean pass can be luck or fatigue. The exit demands a *repeated* clean result, after a groundwork pass has primed the work. |
| Two consecutive | Proves the artifact is stable, not that one reviewer happened to miss things. |

---

## 3. Worked example of a round sequence

Read each row as "what the round found → what it does to the streak → may we stop?"

| Round | Outcome | Clean streak | Floor met? | Stop? |
|---|---|---|---|---|
| 1 | FAIL — found a stale reference (groundwork) | 0 | no | no — round 1 is groundwork; it primes the work and does not count toward exit |
| 2 | CLEAN | 1 | no | no — floor not yet 3 |
| 3 | CLEAN | 2 | yes | **YES** — floor met, last two (2, 3) both clean |

A different run, where a late round reopens an issue:

| Round | Outcome | Clean streak | Stop? |
|---|---|---|---|
| 1 | CLEAN (groundwork) | 0 | no — round 1 is groundwork; it does not count toward exit |
| 2 | CLEAN | 1 | no — streak only 1, and floor not met |
| 3 | FAIL — a fix broke a caller | 0 (reset) | no |
| 4 | CLEAN | 1 | no — only one clean since the reset |
| 5 | CLEAN | 2 | **YES** — floor met, 4 and 5 consecutive clean |

The shortest possible converged sequence is **3 rounds**: round 1 FAIL or
groundwork-clean, then two consecutive clean. The shortest *all-clean* sequence
still takes **3** (round 1 is groundwork; rounds 2–3 are the qualifying pair).

---

## 4. Two gates: LIGHT feeds HEAVY

Keel uses the same round/cadence machinery at two scopes. The light gate is an
early-catch net; the heavy gate is the completion seal.

| | **LIGHT gate** | **HEAVY gate** |
|---|---|---|
| **When** | Immediately after producing *each* artifact (a design, a spec, a plan), before it is surfaced or the next stage begins. | Before any "done" — sealing a plan, merging, or any context reset / hand-off. |
| **Rounds** | **One** genuine coherence pass. | The **full cadence** (§2): min 3, exit on 2 consecutive clean. |
| **Scope** | Just the artifact that was just produced. | The whole change + its hand-off (docs, memory, repo state, tests). |
| **Run by** | The author, immediately, inline. | Independent reviewers in **fresh context** (§6), one per round. |
| **Purpose** | Catch the defect *at the artifact that introduced it*, so it never reaches the heavy gate. | Confirm readiness — by this point it should be confirmation, not discovery. |

**The relationship:** the light gate *feeds* the heavy gate. If light gates do
their job, the heavy gate's rounds come back clean fast — the heavy ritual
becomes confirmation rather than bug-discovery. When the heavy gate keeps
*finding* things, that is a signal the light gates upstream were skipped or
shallow.

> The light gate is the author reviewing their own artifact before surfacing it
> — the author *is* the first reviewer. Never surface an artifact that has not
> passed its own light pass, and state what the pass checked and what it found or
> changed.

### High-leverage artifacts get the full cadence

Three artifacts are leverage-heavy enough that *each one*, on production, gets
the **full** cadence (not just one light pass), in order:

1. the **spec** (the written design),
2. the **implementation plan**,
3. the **execution-approach decision** (how the plan will be carried out).

The earlier, informal brainstorm/design stage gets only the **light gate** (one
coherence pass); the leverage — and the full cadence — kicks in at the *written*
spec. (See [`04-LIFECYCLE.md`](04-LIFECYCLE.md) §2.)

Convergence on these *is* approval — proceed to the next stage on convergence;
do not stop to ask for a go-ahead. (See [`04-LIFECYCLE.md`](04-LIFECYCLE.md) §2,
Convergence is approval.)

---

## 5. The lens menu

Each round must judge through explicit lenses. Two families:

**Quality lenses** — is the artifact *good*?

| Lens | The question |
|---|---|
| **Correct** | Does it actually do/claim the right thing? |
| **Relevant** | Does it address the real problem, nothing extraneous? |
| **Plausible** | Are the assumptions and estimates believable? |
| **Well-specified** | No TBD / TODO / "handle errors" / vague steps; real code, real commands, real expected output. |
| **Well-formed** | Clear, consistent structure; a reader can follow it cold. |

**Coherence lenses** — does it *hold together* against everything else?

| Lens | The question |
|---|---|
| **Drift vs live code** | Every file / line / function / anchor it cites still exists and matches reality. Re-check against the code — never from memory. |
| **Backward-compat** | No change breaks an existing caller, test, default, or contract; new config has safe defaults; a signature change accounts for *every* call site. |
| **Identifier-boundary footprint** | For a rename or split-identifier change, the *full* cross-boundary footprint is accounted for — redirects/routes, build/container files, CI, root scripts, and every consumer that filters on the old value — not just the definition site. An exact-match boundary breaks silently; a path-keyed tool can show clean while consumers break. |
| **Constraint-vs-behavior joint-satisfiability** | When an artifact asserts *both* a hard constraint ("X is off-limits / unchanged") and a behavior only X could deliver ("gate / alter / observe what X owns"), the two are jointly satisfiable — a seam delivers the behavior without touching X — before both are settled. An atomic operation exposing no hook can't satisfy both; catch it at the spec, not three rounds later. |
| **No placeholders** | Nothing deferred with a vague stub; concrete throughout. |
| **Internal + cross-artifact consistency** | Names, types, decisions agree across design ↔ spec ↔ plan; every requirement maps to a task. |
| **Docs + memory currency** | Nothing in the docs or durable notes is now stale or contradicted; the front-door / "start here" pointers route a fresh reader to the *current* state, not a finished one. |

### Vary the lens emphasis per round

Do **not** run the same checklist identically each round — that produces three
copies of one pass, not three independent passes. Give each round a **distinct
lens emphasis** so the passes are diverse:

- Round 1 (groundwork): broad sweep — quality lenses + obvious drift.
- Round 2: deep on coherence — backward-compat and cross-artifact consistency.
- Round 3: deep on currency — docs/memory drift, front-door pointers, hand-off completeness.
- Later rounds: rotate emphasis toward whatever the prior fixes touched.

The streak still requires two *consecutive* clean rounds — but each clean round
should have looked through a *different* primary lens, so "clean" means "clean
from multiple angles," not "clean from the same angle twice."

---

## 6. Fresh-context independence (and parallel reviewers)

The heavy gate's rounds carry the most weight when each is run by an
**independent reviewer in a fresh context** — a separate agent session, a second
AI, or a different person who has *not* been in the working conversation.

Two reasons:

1. **It keeps the heavy reading/searching out of the working context.** The
   completion gate often fires exactly when the working context is already full
   (right before a reset/hand-off). Off-loading each round to a fresh reviewer
   keeps the main thread light.
2. **A reviewer with no memory of the work is the truest test of whether the
   *written* hand-off is self-sufficient.** It simulates the cold-start reader —
   the next session, the next engineer. The original author is biased by context
   the next reader will not have; the fresh reviewer is not. If the written
   artifact + hand-off does not let a cold reader reconstruct the state, the
   gate should fail.

You can **fan out** multiple fresh reviewers in parallel for read-only audit
rounds (no shared mutable state), then have a single owner apply the fixes
between rounds. (Writing fixes is single-writer; see
[`02-RITUALS.md`](02-RITUALS.md) — Ritual 13, Parallel-work synchronization.)
That fan-out is **breadth, not a shortcut past the cadence** — the next two
subsections make the distinction precise and add the one piece a parallel loop
needs to actually converge.

### Breadth within a round, depth across rounds

Parallelism lives **inside** a round, never across the streak. Keep the two axes
separate:

- **Breadth (parallel).** Within one round, fan out **K reviewers at once**, each
  pinned to a *distinct* lens (§5), all reading the **same frozen snapshot** — no
  fixes land mid-round. The round's outcome is the **union** of what they find:
  CLEAN only if *every* reviewer is clean; a single real finding by any reviewer
  FAILs the whole round.
- **Depth (serial).** The streak still counts **rounds**, and rounds stay
  **serialized** — each new round reads the snapshot the previous round's fixes
  produced, so "two *consecutive* clean" stays well-defined. The agent running the gate owns
  the decision to stop; it is never delegated to a reviewer.

So **do not collapse three rounds into one K×3-reviewer fan-out.** That buys
breadth at the price of the cadence, and "consecutive" loses meaning. Run K
reviewers *per* round, then the next round. Done this way the floor and the
two-consecutive-clean exit hold bit-for-bit, and the bar only *rises*: a clean
round now means K independent clean verdicts through K different lenses, not one
reviewer's single look. Scale K to the artifact's leverage — a few for an
ordinary gate, more at the completion seal.

### The findings ledger

A parallel, multi-round loop needs one shared artifact the bare cadence does not
name: a **findings ledger**. Without it, fresh reviewers — who by design carry no
memory of prior rounds — keep re-reporting issues already fixed or consciously
declined, the streak never cleanly resets, and the loop can **oscillate and never
converge**.

Track every finding with a state — **open · fixed · wontfix** (a one-line reason
for *wontfix*) — and have the single fixer update it between rounds. Hand each new
reviewer the ledger as context: *"these are known — report only a NEW issue or a
genuine regression of a fixed one."* A round is **CLEAN when it surfaces no new
open finding**; a re-report of a `wontfix`, or of a `fixed` item that is still
fixed, is not new and does not reset the streak. The ledger doubles as the
round-by-round evidence §7 asks you to surface.

#### CLEAN is severity-defined, not zero-findings

Whether a finding is **open** is decided by its **severity** — this is *how* the
ledger's open/dispositioned split gets made, not a competing definition of CLEAN.
**Tag every finding `blocker` · `major` · `minor`.** Then:

- A **blocker or major** is an `open` finding: it *needs* changing, so it **FAILs
  the round and resets the streak** until fixed.
- A **minor** is **dispositioned by the agent running the gate** — *accept* (note it and move on),
  *defer to BACKLOG* (a stable-ID item for later), or *fold in* (fix it now) —
  and the chosen disposition moves it to `fixed`/`wontfix` in the ledger. A
  dispositioned minor is **not** an open finding and does **not**, by itself,
  reset the streak.

So a **CLEAN** round is one with **no new open (blocker/major) finding** — *not*
one with zero findings of any kind. This matters because a genuinely adversarial
reviewer almost always surfaces *some* minor nit; defining CLEAN as
zero-findings means the streak never reaches two-consecutive and the gate loops
forever, burning effort. The **agent running the gate dispositions minors and owns the verdict.**
When the **blocker/major count is trending to zero while only minors linger**,
that is the signal to **disposition the minors and converge** — not to spin
another round chasing nits.

### A fix is itself a new change

Between rounds, the fixer applies fixes — and **each fix is a fresh, unreviewed
change.** Two things must happen before the next round can come back clean:

1. **Re-verify the fix against the source of truth.** A fix can be wrong, or can
   break a caller (the round 3 → FAIL in the §3 worked example is exactly this).
   Confirm it actually holds against the live code, not against the intent.
2. **Re-grep the *whole* doc funnel for the corrected fact.** A fixer scoped to
   only the flagged file leaves sibling artifacts carrying the same now-wrong
   fact — the same value lives in, or is referenced from, more than one place.
   Search every occurrence and reconcile them (the one-canonical-location
   discipline, [`02-RITUALS.md`](02-RITUALS.md) Ritual 14 / 5). Fixing one copy
   while a stale twin survives is how a "fixed" finding silently regresses two
   rounds later.

This is why a FAIL **resets the streak**: the change a fix introduces has not yet
survived a clean round of its own.

### Verify citations against live code

Every cited file path, line number, or symbol must be **checked against the
live code** in the round — re-read it, re-search for it. Never confirm a
citation from memory or from a prior round's notes. A round that trusts memory
is not adversarial; stale anchors are one of the most common things these gates
exist to catch.

---

## 7. Evidence over assertion (the claim gate)

Tie this to Keel's core value: **never assert "done" / "clean" / "ready" /
"in sync" without showing the verification in the same breath, before the
claim.** For the heavy gate specifically:

- Run and **show** the readiness sweep (clean working tree, tests green,
  front-door currency, hand-off completeness) *before* claiming ready.
- Report **each round's findings transparently** — what was checked, what was
  fixed, pass/fail — so an outer reviewer can spot-check that the rounds
  genuinely happened.
- An outer "are you sure that's all?" is a **spot-check of the inner rounds**,
  not the trigger for them. Catching yourself about to claim done *without* the
  completed cadence is the violation — stop, run it, then speak.

---

## 8. Quick reference

```
ROUND      = one adversarial pass → FAIL (fix, reset streak) or CLEAN (+1)
FLOOR      = min 3 rounds, always
GROUNDWORK = the 1st round does NOT count toward exit (even if clean)
EXIT       = floor met AND last two rounds both CLEAN (consecutive)
NOT EXIT   = a single clean after a fail; two clean before the floor
CLEAN      = no NEW OPEN finding — blocker/major only; minors are dispositioned
             by the agent (accept/defer/fold-in), NOT zero-findings-of-any-kind
FIX        = itself a new change → re-verify vs live code + re-grep the funnel
             for the corrected fact before the round counts clean
PARALLEL   = K reviewers WITHIN a round (distinct lenses, same snapshot);
             rounds stay serial — never collapse N rounds into one fan-out
LEDGER     = findings tracked open·fixed·wontfix + severity; each reviewer reports
             only NEW findings → the parallel loop converges instead of oscillating
LIGHT GATE = 1 coherence pass per artifact, inline, by the author  → feeds →
HEAVY GATE = full cadence, fresh-context reviewers, before any seal/reset
LENSES     = correct·relevant·plausible·well-specified·well-formed
             + drift·backward-compat·no-placeholders·consistency·currency
             (distinct emphasis per round; verify citations vs live code)
```
