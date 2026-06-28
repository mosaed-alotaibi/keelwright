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

## 6. Fresh-context independence

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
LIGHT GATE = 1 coherence pass per artifact, inline, by the author  → feeds →
HEAVY GATE = full cadence, fresh-context reviewers, before any seal/reset
LENSES     = correct·relevant·plausible·well-specified·well-formed
             + drift·backward-compat·no-placeholders·consistency·currency
             (distinct emphasis per round; verify citations vs live code)
```
