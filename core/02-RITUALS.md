# Keelwright — The Rituals

> The standing rituals that govern every phase, plan, and work session. These
> are long-lived: they apply across the whole lifecycle loop, not to any single
> task. Where a ritual conflicts with a tool's default behavior or a generic
> heuristic, the ritual wins — the owner is in control.

These rituals are **tool-agnostic**. They read sensibly whether the actor is an
AI coding agent, a second AI in a fresh session, or a human team. Wherever a
ritual calls for "an independent reviewer in a fresh context," that means any of:
a separate agent session, a different AI, or a different person — whichever you
have. Concrete mechanics for a specific tool (how to spawn that reviewer, where
durable notes live, which hook fires the reminder) belong in
[`../adapters/`](../adapters/) — e.g. `adapters/claude-code/`. The core stays
generic on purpose.

Two terms used throughout:
- **Durable notes** — the cross-session record you own and control (the resume
  cursor, the front-door docs, any persistent memory). See
  [`01-DOC-MODEL.md`](01-DOC-MODEL.md).
- **Independent reviewer (fresh context)** — a reviewer with **no memory of the
  work**, so it tests the *written* handoff, not what's in someone's head.

**Standing principle these rituals serve.** A functioning **and** hardened
end-state outranks velocity or scope-trimming — close latent risks while context
is fresh, without gold-plating. The rituals below are *how* you reach that bar;
the bar itself is principle #2 ("Harden, don't defer") in
[`00-PHILOSOPHY.md`](00-PHILOSOPHY.md).

---

## Rituals at a glance

| # | Ritual | One-line |
|---|--------|----------|
| 1 | Completion ritual | Before any "done": ≥3 fresh re-audit rounds, exit on 2 consecutive clean (from round 6 onward, one clean round exits); never claim done without a shown verification sweep. |
| 2 | Verification-driven, not test-ritual-mechanical | Tests derive from claims and verify behavior at real surfaces; don't over-test internals. |
| 3 | Proactive-but-cautious tool use | Never ask before read-only actions; always trace effect first; always confirm before destructive/irreversible ops. |
| 4 | Don't hand-curate tool-owned state | A tool's regenerated files aren't yours to edit; keep the durable record where you own it; ignore the tool's state dir. |
| 5 | Per-artifact coherence pass | After producing each design/spec/plan and before surfacing it, run one genuine adversarial coherence pass; state what it found. |
| 6 | Live verification of user-facing surfaces | Drive the real surface and inspect actual output before claiming a UI/behavioral change works; pure-backend verifies via tests/API. "Works" ≠ "looks right" — visual changes also need explicit owner look-approval. |
| 7 | Test-effectiveness audit | Passing ≠ sufficient; audit that each test would actually fail if the behavior broke; name gaps. |
| 8 | Own the review gate | The agent self-reviews spec/plan/execution-approach to convergence and auto-proceeds; owner go/no-go only on genuine decisions. |
| 9 | Context budget & resume-safe handoff | The agent can't self-measure context; keep the durable handoff always-current so a reset is safe at any moment. |
| 10 | State-change currency | Right after any durable state change, reconcile the front-door docs + durable notes for stale claims; prefer drift-proof phrasing. |
| 11 | External-dependency feedback (conditional) | For a component you can't change, keep one living evidence-backed enhancement report for its owner; "nothing new" is a valid pass. |
| 12 | Lessons-learned capture | At session end, append Issue / Mitigation / Lesson one-liners to a dated log; "nothing notable" is a valid pass. |
| 13 | Parallel-work synchronization | Read-only fan-out is free; parallel writers only on disjoint files; shared-hub edits and rituals are single-writer. |
| 14 | Documentation model & anti-drift | Funnel + stable IDs + one canonical location per item. (See `01-DOC-MODEL.md`.) |
| 15 | Housekeeping adjudication | *Agent-originated* cleanup that deletes a tracked file/git-ref, mutates committed config, reaches outside the task's diff, or isn't undoable by one named command gets **one** fresh adversarial pass before acting; owner-requested chores are exempt; one pass then the orchestrator decides — escalate to the owner, never a second reviewer round. |
| 16 | Dependency-reality check | Before designing against an unfamiliar / fast-moving / post-knowledge-cutoff dependency, verify its *real* behavior against the **installed package's** source/types — error & return semantics, exact export paths, which helper wraps which behavior, current CLI/version — pin the exact version, and treat a fast release cadence as a standing patch obligation. Designing from priors yields plausible-but-wrong config. |
| 17 | Live eval bar for agent-behavioral surfaces | A surface where an LLM decides the output is verified **statistically**, never by one good turn: ≥20 live shots through the real product path, graded against ground truth the agent cannot see, ≥95% to pass, on a stack spawned from the branch under test, with a pre-registered protocol. |

---

## 1. The completion ritual

**Trigger:** before *any* claim or act of completion — sealing a plan, merging,
handing off, resetting/clearing context, or any "we're done" milestone.

**The rule.** Completion is earned by re-audit, not asserted. Two parts:

1. **Non-skippable claim gate.** Never assert "done" / "complete" / "safe to
   reset context" / "in sync" without, in the *same turn and before the claim*,
   running and **showing** a verification sweep: clean working tree, tests green,
   front-door docs + durable notes current, expected-untracked-only. If anything
   is stale → fix → re-verify → *then* claim. The owner asking "are you sure?" is
   an **outer** check; it must never be what first triggers the sweep.

2. **The re-audit rounds.** Run **at least 3 rounds**, and exit only when the
   **two most recent rounds are both clean**. The first clean round is mandatory
   groundwork and does **not** count toward the exit. A round that finds a gap is
   a *fail*: fix it, then continue — a fix **resets the streak** (the two clean
   rounds must be consecutive). Earliest possible stop is round 3. **From round 6
   onward the relief valve opens:** a single clean round exits (a FAIL at 6+
   still needs a subsequent clean round) — see
   [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §2 (rule 5).

**A passed task/artifact gate is NOT a sealed completion.** Clearing the
per-artifact coherence pass (Ritual 5) or a convergence cadence (Ritual 8) on the
*work itself* does not make it "done" — "done" is earned only by **this**
multi-round completion sweep over the whole change *and its hand-off*, run
**proactively** before any done/seal/merge/hand-off/context-reset. Task momentum
makes this the easy step to skip ("the plan converged, surely we're finished") —
that is exactly when to run it. Per-artifact reviews **feed** the completion
ritual; they never **substitute** for it.

**Inbound claims get the same evidence bar as your own.** A defect or risk claim
you *receive* — from a person, a tool's output, or another agent — is verified
against the live code with **concrete file-and-line evidence before you act on
it**, exactly as you would verify a "done" you're about to assert. Acting on an
unverified report is the inbound twin of asserting an unverified "done". And
**refuting the headline is not the end of the check**: when the literal claim
doesn't hold, identify the **adjacent config or layer the reporter may actually
mean** — a reporter who names the wrong file often still smelled a real problem
one layer over, and that neighbour is frequently the true exposure. Disprove the
exact words, then confirm the neighbourhood is clean too before closing it.

**How to apply.**
- Run each round as a **fresh independent reviewer with no memory of the work.**
  This is the crux: a cold reviewer is the truest test of whether the *written*
  handoff is resume-ready — it simulates the next session's reader, who won't
  have the conversation's context. Inline self-review by the actor is biased by
  what it already knows.
- Each round genuinely re-checks through these lenses (don't rubber-stamp the
  prior round):
  - **Durable-notes coherence** — all persistent notes agree; no stale
    "current work" markers.
  - **Front-door currency** — entry-point docs route a fresh reader to the
    *current* phase, not a shipped one (README / roadmap / next-steps / any
    "start here" table).
  - **Handoff completeness** — operational prereqs covered (services up, env
    present, deps installed, tests verified); any cited revision matches reality
    (prefer "run the log command" over pinning a commit id that drifts).
  - **Repo state** — clean tree, tests green, only expected untracked files.
  - **Test effectiveness** — the suite would actually catch a regression
    (see Ritual 7).
  - **Operational sanity** — the *documented* run/boot commands work from a
    clean state (kill stray processes first; don't trust a smoke against a
    leftover process or inherited env). Killing isn't enough: confirm a running
    server's command path belongs to *this* checkout before trusting it as "the
    app" — a leftover server from another or archived checkout can hold the
    canonical ports and you can verify against the wrong codebase — and key
    environment surfaces off a stable URL path, not a hardcoded port.
  - **Visual sign-off** — any user-facing visual change in scope has explicit
    owner look-approval, not just live-verification that it works (Ritual 6).
  - **Decision-vs-reality drift** — no locked decision the code silently
    contradicts (documented overrides are fine).
  - **Commit narrative** — a stranger reading the log understands the path.
- Report each round's findings transparently, so the outer check can spot-check
  that the rounds actually happened.

**Why.** The expensive failures are the ones a cold reader hits *after* the
context that would have explained them is gone. This ritual moves that discovery
before the reset. The lighter early-catch gate (Ritual 5) aims to make this final
ritual a *confirmation*, not a bug hunt.

---

## 2. Verification-driven, not test-ritual-mechanical

**Trigger:** whenever you write or change a test.

**The rule.** Tests are derived from **business and technical claims**, and they
verify **behavior at real surfaces** (user-facing or system-facing) — not
implementation details. Test-first discipline (write the test → see it fail →
make it pass) applies to **behavioral** tests; skip the ceremony for purely
internal helpers with no business meaning. Over-testing internals is friction;
under-testing real surfaces is risk. Validation drives the code, not the reverse.

**How to apply.**
- Before writing any test, ask: *"What business or technical claim does this
  verify?"* If the answer is "the code I'm about to write works," rewrite it at a
  higher surface or drop it.
- **Do** test claims a user or operator cares about — "a signed-in user can
  create an item and see it in their list"; "a request without a valid token is
  rejected"; "after the flow, exactly one audit row exists." If these pass, the
  system works; if they fail, something real is broken.
- **Don't** test wiring for its own sake — "this index exists"; "the DB handle is
  non-null"; "config loads the port from env." If a behavioral test already
  covers that path, these are noise; if none does, the *missing behavioral test*
  is what to write.
- Schema-presence checks have some migration-regression value, but prefer
  behavioral tests at the API / route / UI surface when both are feasible.

---

## 3. Proactive-but-cautious tool use

**Trigger:** every action that touches the system through a tool or shell.

**The rule.** Quick where it's safe, cautious where mistakes cost real work —
both at once. A functioning system is what matters at the end, so it's always
fine to ask when genuinely unsure.

**How to apply.**
- **Never ask** before **read-only** actions — read a file, list a directory, run
  tests, build, type-check, inspect status/log/diff, list processes, query
  read-only, hit a local endpoint. Just do it.
- **Always trace the effect** of a command *before* running it. If you can't
  predict the resulting state change, you don't understand the command yet — look
  it up first. This double-check is mandatory.
- **Always confirm** before **destructive or hard-to-reverse** ops:
  - file mutation outside the intended diff (delete, move, overwrite),
  - data mutation (drop, truncate, delete, unscoped update),
  - process control (force-kill, mass-kill, hard stop),
  - history/repo destruction (hard reset, force-delete branch, force push,
    forced clean),
  - anything irreversible without an undo.

---

## 4. Don't hand-curate tool-owned state

**Trigger:** about to edit a state/config file you didn't author.

**The rule.** Some files are **owned by a tool** — they have a schema and a
lifecycle the tool controls, and the tool **regenerates them**. Hand-editing such
a file is at best futile (the tool overwrites it) and at worst quietly wrong
(schema drift). Before editing any state file you didn't author, identify its
owner and lifecycle.

**How to apply.**
- If a tool regenerates it, **don't hand-curate it.** Put the durable record
  where **you** own it — the plan docs, the handoff notes, the commit history,
  your persistent notes.
- **Ignore the tool's state directory** in version control (any tool-owned state
  dir): the file can live on disk for the tool's local use without being tracked
  or hand-maintained. The real progress trail is your own docs, not a tool's
  auto-checkpoint.

---

## 5. Per-artifact coherence pass

**Trigger:** immediately after producing each **design**, **spec**, or
**implementation plan** — *before* moving to the next stage **and before
surfacing it to the owner.** A design **presented in conversation** counts as an
artifact, just like a written file; it gets this pass before it reaches the owner.

**The rule.** The owner is always the *second* reviewer, never the first. Run
**one** genuine adversarial coherence pass over the just-produced artifact and
**state what it checked and what it found or changed** — an asserted "looks good"
is not a pass; the findings *are* the evidence the pass ran. The owner reads the
artifact async, for visibility — not as an approval you block on.

**How to apply.** A single pass through these lenses; fix findings inline (or
surface them if they need a decision), then proceed:
- **Drift vs reality** — every file / line / function / anchor the artifact cites
  still exists and matches the live code. Re-check; don't trust memory.
- **Premise vs reality** — every *existing-behavior* premise the artifact builds
  on is re-verified against the live code, not taken on its label. A feature
  called "dead" / "mock" / "redundant", an assumed test harness, a "current
  state" inherited from a catalog or a prior note — each is a **hypothesis to
  confirm, not a fact**. Designing on top of an unchecked premise propagates the
  error into everything downstream; confirm the premise before you rely on it.
  (A "remove / simplify X" premise hides the same trap — confirm X is the
  surface feature, not a shared backbone X merely *rides on*, before specifying
  its removal; the brainstorm-stage version is in
  [`04-LIFECYCLE.md`](04-LIFECYCLE.md) §2.)
- **Backward-compat** — no change breaks an existing caller, test, env default,
  or contract; new config has safe defaults; a signature/return-type change has
  *every* call site accounted for.
- **Identifier-boundary footprint** — for any **rename or split-identifier**
  change (a value that splits into a "visible" and a "technical" form, or moves
  namespace), enumerate the **full cross-boundary footprint**, not just the
  obvious definition site: callbacks/redirects/routes, build/container files,
  pipeline/CI config, root-level scripts, and every downstream consumer that
  *filters on* the old value. Two traps make this silent: an **exact-match
  boundary** (a redirect or route off by a single character) fails with no error,
  and a **path-keyed tool** can report a clean lockfile while consumers built on
  the old identifier quietly break. Grep every surface for both forms before
  calling the rename complete.
- **Constraint-vs-behavior joint-satisfiability** — when an artifact asserts
  **both** a hard constraint ("component / file X is off-limits / stays
  unchanged") **and** a behavior that only X could deliver ("gate / alter /
  observe what X owns"), verify the two are **jointly satisfiable** *before*
  recording both as settled: a seam must exist that delivers the behavior
  **without touching X**. An *atomic* operation that exposes no hook satisfies the
  constraint or the behavior but not both — and a spec that locks in the
  contradiction surfaces it three rounds later as an "impossible" task. Find the
  seam (a wrapper, an interception point, a side channel X already emits), or
  surface the conflict as an owner decision now; don't settle both halves until
  one of those holds.
- **No placeholders** — no TBD/TODO/"handle errors"/vague steps; code steps show
  real code; commands show expected output.
- **Internal + cross-artifact consistency** — types, names, and decisions agree
  across the spec and the plan; every spec requirement maps to a plan task.
- **Docs + notes currency** — nothing in docs or durable notes is now stale or
  contradicted; sweep the front-door docs for stale "active phase" / resume
  pointers so a fresh reader lands on the *current* phase.

**A fix is itself a new change.** When this pass surfaces something and you fix
it, the fix is a fresh edit that has not yet been reviewed — so **re-verify the
fix against the source of truth** before treating the pass as clean, and
**re-sweep the whole doc funnel for the corrected fact.** A fixer scoped to only
the flagged file silently leaves sibling artifacts carrying the same now-wrong
fact (one-canonical-location, Ritual 14): the same value lives in — or is
referenced from — more than one place, and correcting one instance creates drift
unless you re-grep for *every* occurrence and reconcile them. Fix → re-verify →
re-grep, then the round may count clean.

**Why.** This is the **light early-catch gate**: it catches issues at the
artifact that introduced them (a stale anchor, an unchecked caller, a
placeholder), so the heavier completion ritual (Ritual 1) is confirmation, not
discovery. It *feeds* Ritual 1; it does not replace it.

---

## 6. Live verification of user-facing surfaces

**Trigger:** any change with a visible UI or user-facing behavioral surface,
before claiming it works.

**The rule.** Render and exercise the change **at the real surface** and inspect
the **actual** result — never claim a UI/behavioral change works from
code-reading alone. Then surface that evidence (the rendered output, a captured
screen, the resulting record).

**How to apply.**
- Drive the real surface **headlessly** and inspect the output it actually
  produces — load the route, perform the real action/turn, capture the result,
  then examine the captured artifact (not the intended one). The *mechanism* is
  generic; the specific driver is an adapter concern (see
  [`../adapters/`](../adapters/)).
- For changes that span a flow (e.g. an authenticated, streamed interaction),
  exercise the **whole flow** at the surface, not just a static render.
- **"Works" and "looks right" are separate gates.** Live verification proves a
  surface *functions*; it does **not** prove the owner approves the *look*. For
  any user-facing **visual** change, surface the rendered evidence (screenshots)
  and obtain **explicit owner look-approval before claiming done.** The functional
  gate is the agent's to close; visual quality is an owner call. (This is the one
  visual exception to Ritual 8's "convergence = approval, don't wait" — a converged
  *functional* surface still needs an explicit owner nod on its appearance before
  it counts as complete.)
- **Exempt:** pure-backend changes with no visible surface — verify by tests, an
  API call, or a data query instead.
- **Catches what the harness can't.** A guarantee that a hermetic test harness
  force-disables or cannot observe (origin/CSRF rejection, a top-level redirect,
  cross-origin cookie behavior) gets its **end-to-end proof here** — the harness
  only asserts the configuration (Ritual 7).
- **Prove the value/state actually in effect — don't trust on-disk or assumed.**
  When you change configuration a process reads **at startup**, **restart the
  process** before verifying: hot-reload of *source* does not reload *startup
  config*, so confirm the new value is genuinely in effect, not merely saved to
  disk. And when a failure could stem from a **placeholder / example value**
  rather than a genuine error (a copied example secret fails *identically* to an
  expired or wrong one), **fingerprint the actual value in use** — e.g. its length
  and first characters against the known-good source — before diagnosing.

**Why.** The visual/behavioral analogue of "evidence over claims" (Ritual 2):
the rendered reality is frequently not the intended one — and a surface that works
is not the same as a surface that looks right.

---

## 7. Test-effectiveness audit

**Trigger:** (a) whenever tests are **added or changed**, and (b) as an explicit
lens inside the completion ritual (Ritual 1).

**The rule.** Passing tests are necessary but not sufficient — periodically audit
that the tests you *have* are worth their weight. This applies to **every test
type**: unit, integration, end-to-end, evaluation harnesses, smoke. It complements
Ritual 2 (which governs *how* to write tests); this is the audit that the existing
suite genuinely protects behavior. Never report "N passed" as proof of quality on
its own — the audit's *conclusion* is the evidence.

**How to apply.** Review through these lenses and **fix-or-log** findings:
- **Would it actually fail?** Each test would fail if the behavior it protects
  broke. No tautologies; no asserting only on a mock's own return value; no test
  that passes regardless of the implementation.
- **Right surface & level.** It verifies real behavior at a meaningful boundary,
  at a level that fits what's being checked — not over-testing internals, not
  under-testing real surfaces.
- **Covers the real risk.** Error / edge / empty / permission / failure paths are
  tested, not just the happy path. **Name the gaps** rather than hiding them.
- **Honest, not gamed.** No result-gaming, no over-mocking that hides the very
  integration being claimed, no assertions weakened just to go green.
- **Harness-unobservable guarantees → assert config, prove live.** Some
  properties are **force-disabled or structurally unobservable** under a hermetic
  test harness — e.g. origin/CSRF rejection, a top-level redirect, real
  content-type handling, cross-origin cookie behavior. A green hermetic suite is
  **not** evidence for a guarantee it cannot exercise. For each such property,
  split the proof: assert the **configuration** in the harness (the flag is set,
  the trusted list is exactly right), and explicitly route the **end-to-end
  proof to live verification (Ritual 6)**. Naming which guarantees are
  harness-unobservable is itself part of this audit.
- **Reasonable cost.** Not flaky, not redundant; fast where it can be;
  deterministic. Tests that mutate **shared state against a single live datastore**
  must be **serialized**, not run under blanket file-parallelism (the race erodes
  the green signal); and scope module-load-time env **per test file** so a global
  default can't poison a negative-path test.

Weak / vacuous / missing tests are fixed inline or logged as named gaps.

---

## 8. Own the review gate (convergence cadence)

**Trigger:** immediately after the agent finishes each of three **high-leverage
artifacts**, in order: (1) a **spec**, (2) an **implementation plan**, (3) the
**execution-approach decision** (how to execute the plan — parallel fan-out /
sequential / inline / hybrid).

**The rule.** The agent reviews its **own** artifacts; the owner does **not**
review them personally and does not need to ask. After each artifact, run the
convergence cadence below, then proceed to the next stage automatically.

**Convergence = approval. Do not wait.** When the cadence converges (floor met, 2
consecutive clean), the artifact is **approved by default**: proceed immediately
to the next stage and drop the artifact in the conversation for the owner to read
async. Do **not** stop to ask "does this look right / shall I proceed?" after a
converged artifact — asking for that go-ahead is itself a violation. The loop runs
**end-to-end** (design → spec → plan → execution) without pausing — including not
pausing to propose a context reset (Ritual 9 keeps the handoff current instead).

The owner retains go/no-go **only** on genuine-decision points: merges, pushes,
which milestone to pursue, and gray-area design forks. Never on the *review of an
artifact the agent already converged*.

**The cadence — minimum 3 iterations, exit on 2 consecutive clean passes.**
An iteration = one genuine adversarial pass that either finds issues (→ fix
inline; that iteration is a **fail**) or finds nothing needing change (a **clean
pass**).
- **Floor:** always run **at least 3 iterations.** The 1st is mandatory
  groundwork and does **not** count toward the exit, even if clean.
- **Exit:** stop only when the **two most recent iterations are both clean** —
  and the floor of 3 is met. Earliest stop is iteration 3.
- **Keep going in pairs of intent** if not converged: a fail always resets the
  streak; two consecutive clean passes is the gate through round 5.
- **Relief valve:** from round 6 onward a single clean pass exits (a fail at 6+
  still needs one subsequent clean) — [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §2 (rule 5).

**Each iteration is genuine, not a rubber-stamp.** Judge the artifact on
*correct · relevant · plausible · well-specified · well-formed*, plus the Ritual 5
lenses. Use a **distinct lens emphasis** per iteration so passes are diverse.
**Verify every cited file/line/symbol against the live code** — never from memory.
Report each iteration's findings transparently.

**Production is delegated; the review gate is not.** Drafting the spec and the
plan (and executing the plan) is itself delegated to **fresh independent contexts**
so the main loop stays light and never needs a mid-loop reset. The agent
orchestrates and **owns the review cadence** — the convergence gate is never
delegated. The execution-approach decision must explicitly weigh:
- **Fit** — does the work decompose into independent units (→ parallel fan-out /
  judge panels / adversarial verify) or is it a gated chain / small task
  (→ sequential delegation, or inline for trivial work)?
- **Context cost** — inline consumes the main context heavily; delegated contexts
  isolate it but cost more agents/tokens. Pick the lightest approach that fits.
- **Always name** whether a parallel/orchestrated approach is right and why the
  chosen approach beats it for this task — don't silently default.

**Relationship.** This operationalizes Ritual 5 into a convergence-gated cadence
for the three highest-leverage artifacts, and it *feeds* the completion ritual
(Ritual 1).

---

## 9. Context budget & resume-safe handoff

**Trigger:** every atomic-unit boundary in the work.

**The rule.** The agent has **no self-meter** for how full its context window is —
it cannot measure that mid-turn. So this ritual is **heuristic and collaborative**,
never a precise auto-trigger.
- **The owner watches the meter** and may call for a context reset at any time.
- **The agent keeps the durable handoff always-current** — the resume cursor plus
  persistent notes are refreshed at every atomic-unit boundary, so a reset is
  **safe at any moment** without losing state.
- **The agent may note in passing that a clean seam exists — but never halts the
  loop to request a reset.** Under Ritual 8 it auto-proceeds (delegated drafting
  keeps the window light). Handoff *currency* is the duty, not a pause.

**Relationship.** Feeds Ritual 1 (the completion ritual confirms the handoff a
reset relies on) and Rituals 5/8/10 (front-door + handoff currency).

---

## 10. State-change currency

**Trigger:** immediately after any action that changes durable project state — a
push, a merge, a phase/milestone **seal**, **deferring/closing** an item, a
**branch** cut, or a config/setting change other docs describe.

**The rule.** A state change can silently falsify what the docs and notes assert
(a push makes "not pushed / N ahead" stale; a merge makes "open request" stale; a
seal makes "in progress" stale). So right after the action — **before ending the
turn** — sweep the front-door docs and durable notes for any claim the change just
contradicted, fix it, and refresh any in-repo mirror of those notes.

**How to apply.**
- Prefer **drift-proof phrasing** over hardcoded facts that re-stale on the next
  change — e.g. "check the ahead/behind count with the log command" instead of "N
  commits ahead."
- **Leave dated history alone.** Archives, dated specs/plans, and "why" notes
  describe past state and stay as-is — only *living* front-door docs and
  *current-state* notes get reconciled.

**Relationship.** Complements Ritual 5 (per-artifact coherence) and Ritual 9
(handoff currency); this one is triggered by *state changes*, not artifact
creation. An optional automated nudge (e.g. a post-action hook) can remind you to
run this sweep — the nudge only reminds; the reconcile itself is this judgment
pass. (See [`../adapters/`](../adapters/) for hook mechanics.)

---

## 11. External-dependency feedback (conditional)

**Applicability.** This ritual is **optional** — it applies only when you depend
on a component you **cannot change**: a vendored host you must not edit, a
third-party service, an upstream library. If you have no such dependency, skip it
entirely.

**Trigger (when it applies):** once per session, as a periodic pass run just
before the completion ritual (Ritual 1).

**The rule.** The only lever you have on a component you can't change is
**influencing its owner.** Keep a **single living, vendor-facing enhancement
report** for it. Each session, run one genuine review pass: *did anything this
session reveal* about that dependency — a limitation, a friction, a capability
gap, a contract divergence, a workaround you had to do *because* it doesn't do X?
- **If yes** → append a new item (or sharpen an existing one), each with
  **problem + evidence (a concrete pointer) + proposed change + benefit +
  priority.** The report only ever grows more rigorous.
- **If nothing new surfaced** → the review **passes**, report unchanged. That's a
  clean outcome, not a gap — don't manufacture items to look busy.

**How to apply.** Run this **inline**, by the actor who lived the session — the
friction lives in *this* session's context, so a cold reviewer wouldn't know what
hurt. Report the outcome (items added, or "pass — nothing new") transparently,
then proceed into Ritual 1. It does **not** gate a reset; a clean pass is fine.
Set a clear north star for the report (e.g. "the host should be a generic,
identity-agnostic harness") so items pull in one direction.

---

## 12. Lessons-learned capture

**Trigger:** every working session, as a pass run just before the completion
ritual (Ritual 1) — alongside Ritual 11.

**The rule.** Before wrapping, write the session's hard-won lessons to a **dated
log** (one entry per session). For each issue, three one-liners: **Issue ·
Mitigation · Lesson.** Group by area (auth, infra, deployment, tooling, local
dev, …). Cover issues of any kind — infra, process, tooling — not just code. Keep
it **concise, precise, direct — no fluff.**

- **If nothing notable surfaced** → the pass **passes**: note "no notable issues"
  or skip. Do **not** manufacture entries.

**Promote the cross-cutting ones.** A lesson that is **cross-cutting** — it will
recur in sibling tasks, not a one-off — does more good as a *standing warning*
than as a dated log entry the next task never reads. When a lesson is
cross-cutting, **promote** it from the dated session log into a standing
**carry-forward checklist** referenced at the **resume cursor** (NEXT-STEPS), so
the next task **inherits** the warning instead of rediscovering it the hard way.
The dated entry stays as history; the carry-forward checklist is the *living*
copy a fresh context reads first. (A one-off lesson stays in the log only.)

**How to apply.** Run this **inline**, by the actor who lived the session (the
friction is in *this* context). It does **not** gate a reset; a clean pass is
fine. Index the entries so the log is navigable. A template lives at
[`../templates/docs/lessons-learned/`](../templates/docs/lessons-learned/).

**Why.** Integration/deployment sessions surface non-obvious, easy-to-forget
gotchas (provisioning order, exact config values, naming-boundary traps).
Capturing them while fresh turns one painful debug into a durable checklist for
the next environment and the next engineer.

---

## 13. Parallel-work synchronization doctrine

**Trigger:** before fanning work out across multiple agents or workers.

**The rule.** Classify each unit before dispatching:
- **Read-only exploration → parallel is free.** Many read-only workers may sweep
  the codebase at once — no shared mutable state.
- **Implementation → parallel ONLY on disjoint files.** Two writing workers may
  run at once **only** when their file sets do not overlap. Before dispatching,
  enumerate each task's **entire** file footprint — not just its "primary" file
  (a task also touches its imports, shared config, an index, a doc). If two
  footprints *might* touch the same file, **serialize** those tasks. A clean
  merge from overlapping edits is luck, not safety.
- **Shared-hub edits → serialize.** Where edits converge on a shared "hub" file
  (a large component or module most tasks touch), they run **one writer at a
  time.**
- **Rituals & doc/notes writes → serial single-writer.** The completion ritual,
  the state-currency reconcile, and any docs/durable-notes write run with a
  **single writer** to avoid lost updates.
- **Don't split shared-hub work across isolated worktrees.** Keep **one working
  tree** for hub-touching work so changes can't silently diverge.

**Why.** Uncoordinated parallel edits to a shared hub produce conflicts and
dropped changes. Disjoint-file fan-out is still encouraged where it's genuinely
disjoint.

---

## 14. Documentation model & anti-drift

**Trigger:** whenever you record an idea, decision, or item in the docs.

**The rule (summary — canonical home is [`01-DOC-MODEL.md`](01-DOC-MODEL.md)):**
- **Funnel.** Docs flow as a funnel from ideas/deferrals → the plan → how-to-resume
  → as-built. Each stage has a defined role; don't restate one stage's content in
  another.
- **Stable IDs.** Items carry permanent IDs that are **never reused or
  renumbered**, so cross-references survive edits.
- **One canonical location per item.** Each fact/decision/item lives in exactly
  **one** authoritative doc; every other mention **references it by ID** and never
  restates the detail.

**Relationship.** Complements Ritual 4 (don't hand-curate the tool-owned backlog;
your own backlog doc is the counterpart you control) and Ritual 10 (state-change
currency keeps the canonical locations current).

---

## 15. Housekeeping adjudication

**Trigger:** before acting on *agent-originated* housekeeping — cleanup the agent
proposes on its own (remove a worktree/branch/scratch dir, prune files, "while I'm
here" tidying) — **not** a chore the owner explicitly asked for.

**The rule.** The action gets **one** fresh independent-reviewer adversarial pass
**before** it happens if it trips **any** of these *objective* triggers:

- deletes or force-overwrites a **tracked file** or a **git ref** (branch / tag /
  remote ref);
- mutates **shared or committed config** (`.gitignore`, settings, CI, infra
  manifests) or any version-controlled file **outside the current task's diff**;
- reaches **outside the current task's worktree/diff** (another branch or worktree,
  global VCS config);
- **cannot be undone by a single inverse command the agent writes out in advance**
  (if it can't name the one-line undo, it is by definition not trivially reversible
  → gate it).

Chores that trip **none** of these — and **any** chore the **owner explicitly
requested** (provenance carve-out) — are exempt: just do them. The reviewer returns
a verdict plus the single strongest counter-argument, and **the orchestrator
decides**. **One pass, then decide** — no multi-round reviewer debate (two reviewers
with no authority only manufacture a consensus the orchestrator would override). If
a single pass is genuinely inconclusive, **escalate to the owner**, never to a
second reviewer round.

**Why this exists.** Post-merge / post-task *janitorial* action sits in a seam the
other gates miss: it is not a binding product decision (so the owner-veto of
Ritual 8 / principle #5 doesn't fire) and it is not the artifact under verification
(so the coherence/effectiveness audits don't fire) — yet a bad call (a force-deleted
ref, a clobbered shared config) is expensive and one-way. The *objective* triggers
deliberately replace a gameable "is it trivial?" self-judgment: the agent that wants
to skip the gate must not be the one ruling the action trivial. The flat single pass
keeps the gate cheap and loop-free.

**Relationship.** Sharpens Ritual 3 / principle #8 (proactive-but-cautious; confirm
before irreversible ops) into an objective trigger set plus a bounded adversarial
pass; the single-writer discipline of Ritual 13 still governs any fix the verdict
produces. The bounded-self-challenge stance behind it is principle #11 in
[`00-PHILOSOPHY.md`](00-PHILOSOPHY.md).

---

## 16. Dependency-reality check

**Trigger:** before designing or building against any dependency whose real
behavior you have not just confirmed — most acutely an **unfamiliar**, a
**fast-moving**, or a **post-knowledge-cutoff** one (a library, framework, SDK,
CLI, or external API you're integrating).

**The rule.** Verify the dependency's **actual** behavior against the **installed
package's own source and type definitions** — not prose docs, not a blog, and
above all not your priors. Documentation lags the code; your training is a
snapshot that a fast release cadence has already moved past. The truth is in the
artifact you actually depend on. In particular, confirm against the installed
version:
- **Error & return semantics** — what it throws vs. returns, the shape of each,
  the failure modes you must handle.
- **Exact export / import paths** — the real module path of every symbol you
  import (priors routinely guess a path that moved or never existed).
- **Which helper wraps which behavior** — when several helpers look
  interchangeable, which one actually does the thing you need.
- **Current CLI / API surface and version** — flags, subcommands, and signatures
  for the version you have installed, not an older or newer one.

Then **pin the exact version** you verified against, and treat a **fast release
cadence as a standing patch obligation**: a dependency that ships often will drift
from your verified snapshot, so re-checking it is recurring maintenance, not a
one-time gate.

**How to apply.**
- Read the **installed** source/types (in the dependency tree on disk), or the
  release notes / changelog for the **exact** installed version — not the latest
  docs site, which may describe a different version than you have.
- When a design decision rests on "the dependency does X," cite **where** in the
  installed package you confirmed X. An unconfirmed "it does X" is a premise to
  verify (Ritual 5, *Premise vs reality*), not a fact to build on.
- If you cannot confirm a behavior from the source, write a tiny probe that
  exercises it and observe the real result — don't assume.

**Distinct from Ritual 11.** Ritual 11 (external-dependency feedback) is about
*influencing the owner* of a component you **cannot change**, once a session, by
logging friction. This ritual is **design-time correctness** against **any**
dependency — changeable or not — *before* you build on it. One looks outward to
report; this one looks inward to verify.

**Relationship.** Feeds Ritual 5 (a dependency premise is one of the premises the
coherence pass re-verifies) and Ritual 2 (a probe that confirms real dependency
behavior is the same evidence-over-priors discipline tests embody). Designing from
priors alone yields config that is plausible but wrong — exactly the class of
defect the early gates exist to catch before it reaches the completion ritual.

---

## 17. Live eval bar for agent-behavioral surfaces

**Trigger:** a verification cycle whose change touches an *agent-behavioral*
surface — anywhere an LLM decides the output: an agent's system prompt, its
tools, the model or its middleware, or a pipeline that consumes the agent's
answers.

**The rule.** A stochastic surface is never verified by a single good turn.
Its verification is a **live eval suite**:

- **≥20 shots through the real product path** — real login, real session, real
  streaming; the path a user takes, not a bench harness that bypasses the app.
  Spawn the stack **from the branch under test** (kill stale listeners first —
  never eval one build while another is serving).
- **Graded against ground truth the agent cannot see.** Derive the answer key
  from the data store directly (hidden labels, direct queries) — never from the
  agent's own outputs. Ground truth over generated/synthetic data is
  **generation-relative**: re-derive the key after every regeneration.
- **Pass bar ≥95%** (e.g. 19/20). Below the bar the cycle FAILS its
  verification, whatever the unit suite says.
- **Pre-register the protocol** — shot list, grading tolerances, retry policy —
  *before* seeing results, so failures cannot be argued away shot by shot. A
  turn-level malfunction (transport error, empty answer) may get ONE
  pre-registered retry; a question that fails twice fails.
- **Grade independently and adversarially.** Graders re-derive every fact with
  their own queries; verdicts get an adversarial verification pass (the Ritual 8
  discipline applied to the grading itself).
- **Record per-shot evidence for attribution** — streamed vs persisted output,
  tool calls, event traces — so a failing score indicts the right layer (agent
  prompt, model, middleware, or app) instead of condemning the whole stack.

**Why one good turn is not evidence.** A demo turn samples the distribution
once. A surface that passes a hand-picked end-to-end check can still fail half
of a systematic suite; only shot *counts* expose failure **rates** and failure
**clusters** — wrong-date grounding, fabrication after a tool error, truncated
final turns — that single-pass verification structurally cannot see.

**Distinct from Ritual 6.** Ritual 6 drives a deterministic user-facing surface
once and inspects the actual output — sufficient when the same input yields the
same output. This ritual exists because an LLM surface gives you a sample, not
an answer; the unit of evidence is the suite, not the turn.

**Relationship.** The eval score is part of the Ritual 1 completion sweep's
evidence; the discipline is Ritual 2's claims-verify-behavior applied to a
stochastic surface; the grading fan-out maps naturally onto the adapter's
parallel-review mechanics (Ritual 8 / the gated-swarm rules).

---

## Where the tool-specific mechanics live

These rituals are the durable, tool-agnostic *what* and *why*. The concrete *how*
for a specific agent or toolchain — how to spawn a fresh independent reviewer, how
to drive a real surface headlessly, where durable notes physically live, which
hook fires the state-change nudge — lives in
[`../adapters/`](../adapters/) (for example, `adapters/claude-code/`). Keep this
file generic; map it onto a tool there.
