# Changelog

All notable changes to Keelwright are recorded here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.4.0] — 2026-07-03

### Added

- **`core/02-RITUALS.md` — Ritual 17: Live eval bar for agent-behavioral surfaces.**
  A surface where an LLM decides the output is verified **statistically**, never by
  one good turn: ≥20 live shots through the real product path, graded against ground
  truth the agent cannot see, ≥95% to pass, on a stack spawned from the branch under
  test, under a pre-registered protocol (tolerances + one retry per turn-level
  malfunction), with independent + adversarially-verified grading and per-shot
  evidence for layer attribution. Distilled from a real campaign: a surface that had
  passed a hand-picked A-to-Z check scored 13/24 on its first systematic suite — the
  failure *clusters* (missing date grounding, fabrication after tool errors,
  truncated final turns) were invisible to single-pass verification. Adapter playbook
  (headless driver + Workflow grading fan-out) in
  `adapters/claude-code/rules/RITUALS-IN-CLAUDE-CODE.md`; glossary term *Live eval bar*.

### Changed

- **`core/03-REVIEW-GATES.md` §2 — the round-6 relief valve.** The cadence keeps its
  floor (min 3 rounds) and its exit (2 consecutive clean), but from **round 6 onward a
  single clean round converges the gate** (a FAIL at 6+ still needs one subsequent
  clean). Rationale: after five genuine adversarial passes, reviewer churn — each
  fresh lens finding something different, small, and new — can deadlock a stable
  artifact; the gate must converge, not oscillate. Echoed across `02-RITUALS.md`
  (Rituals 1 and 8), `04-LIFECYCLE.md`, `05-GLOSSARY.md` (new term *Relief valve*),
  the README, and the claude-code adapter (README, `RITUALS-IN-CLAUDE-CODE.md`,
  `GATED-SWARM.md` orchestrator pseudocode, seed memories).

## [0.3.0] — 2026-07-01

### Renamed

- **The framework is now `Keelwright`** (was `Keel`). The methodology, every doc,
  template, the adapter, the installer internals, and the consuming-project state
  directory (`.keel/` → `.keelwright/`) were rebranded. The **CLI command stays
  `keel`** — `keel init` is the entry point, deliberately kept short like `git`.
  Releases `0.1.0`–`0.2.0` were published under the former name *Keel*; their
  entries below are preserved as history.

### Added

- **`keel` CLI with an interactive `keel init`.** Bootstraps a project the way
  `git init` does — run it in (or point it at) a directory and it asks, interactively,
  for the project name / slug / owner / stack / repo, whether to install the Claude
  Code adapter, and whether to `git init`, then lays down the doc funnel and writes a
  `.keelwright/config` marker. A non-interactive `--yes` + flags cover scripting / CI;
  `--dry-run` writes nothing; it refuses to re-init or to overwrite without `--force`.
  Pure bash, no dependencies, symlink-friendly so it works from `PATH`.
- **`bootstrap/lib/install.sh`** — the install engine extracted so the new `keel init`
  and the legacy `bootstrap/init.sh` share one proven code path (generalize once a
  second real consumer appears).
- **`VERSION`** — a single canonical home for the version, read by `keel`, the
  installer, and the project marker.
- **`CONTRIBUTING.md`** — how changes flow through the framework's own loop + gates,
  the three-layer rule, the CLI test recipe, and the release checklist.
- **`assets/keelwright-logo.png`** + a rewritten **`README.md`** — a logo hero, the
  "why it exists" framing, a `keel init` quick start, the 60-second mental model, and
  an adopt / extend section for open-source contributors.

### Changed

- **`bootstrap/init.sh`** rewritten as a thin non-interactive front-end over the
  shared engine; its documented `<dir> [flags]` interface is unchanged.
- **Installer placeholders** `{{KEEL_CORE_PATH}}` / `{{KEEL_ADAPTER_PATH}}` →
  `{{KEELWRIGHT_CORE_PATH}}` / `{{KEELWRIGHT_ADAPTER_PATH}}` (the templates and the
  substitution map were updated in lockstep). Adapter memory seeds and hook snippets
  now install under `.keelwright/`; the installer scratch suffix is `*.keelwright.tmp.*`.

## [0.2.0] — 2026-06-30

### Added

- **`core/02-RITUALS.md` — Ritual 16: Dependency-reality check.** Before designing
  against an unfamiliar / fast-moving / post-knowledge-cutoff dependency, verify its
  *real* behavior against the **installed package's** source/types — error & return
  semantics, exact export paths, which helper wraps which behavior, current CLI/version
  — pin the exact version, and treat a fast release cadence as a standing patch
  obligation. Designing from priors yields plausible-but-wrong config. Distinct from
  Ritual 11 (influence a dependency you *can't* change); this is design-time correctness
  against *any* dependency, and it feeds Rituals 5 and 2. Added to the "Rituals at a
  glance" table and the `PROJECT_RULES.md.tmpl` adopted-ritual list; glossary entry added.
- **`adapters/claude-code/` — Ritual 15 (Housekeeping adjudication) mapped to its CC
  mechanism.** New row in the adapter `README` ritual table and a `## Ritual 15` playbook
  in `rules/RITUALS-IN-CLAUDE-CODE.md`: spawn **one** bounded adversarial-pass subagent
  before agent-originated destructive cleanup; the orchestrator decides; escalate to the
  owner if inconclusive, never a second round. The bounded single pass is Principle 11.
- **`core/02-RITUALS.md` — Ritual 15: Housekeeping adjudication.** *Agent-originated*
  cleanup that deletes a tracked file/git-ref, mutates committed config, reaches
  outside the current task's diff/worktree, or isn't undoable by one named command
  gets **one** fresh adversarial reviewer pass before acting; owner-requested chores
  are exempt; one pass then the orchestrator decides — escalate to the owner, never a
  second reviewer round. Closes a real seam: post-task janitorial action escapes both
  the owner-veto and the artifact-verification gates. Objective triggers replace a
  gameable "is it trivial?" self-judgment.
- **`core/00-PHILOSOPHY.md` — Principle 11: Challenge — adversarially, and bound it.**
  The agent challenges the owner (real opinions, pushback, never blind obedience) and
  itself (one bounded adversarial self-critique pass, then decide — no infinite
  judgment loop). Self-review (#6) turned adversarial and bounded.
- **`adapters/claude-code/rules/GATED-SWARM.md`** — run Keel's gates and the execute
  phase as a parallel **swarm** without weakening the cadence: the Orchestrator/Worker
  split, "one round = N reviewers → one conservative verdict," race-free funnel/ID
  writes, and Workflow-tool recipes. Pointers added from `CLAUDE.md.tmpl`, the adapter
  `README`, and `RITUALS-IN-CLAUDE-CODE.md`. *Fan out the work, never the gate.*

### Changed

- **`core/02-RITUALS.md` — Ritual 6 (live verification)** gained a **"prove the
  value/state actually in effect — don't trust on-disk or assumed"** caveat:
  restart a process before verifying config it reads **at startup** (hot-reload of
  *source* doesn't reload *startup config*), and when a failure could come from a
  **placeholder / example value** rather than a genuine error, fingerprint the
  actual value in use (length + first chars vs the known-good source) before
  diagnosing — a copied example secret fails identically to a wrong/expired one.
- **`core/02-RITUALS.md` — Ritual 7 (test-effectiveness)** sharpened the
  **"reasonable cost / not flaky"** lens: tests that mutate **shared state against
  a single live datastore** must be **serialized**, not run under blanket
  file-parallelism (the race erodes the green signal); and scope module-load-time
  env **per test file** so a global default can't poison a negative-path test.
- **`adapters/claude-code/rules/RITUALS-IN-CLAUDE-CODE.md` — Ritual 13 section**
  gained an explicit-staging git-hygiene note: when subagents/verification steps
  may have dirtied the tree, **stage explicitly** (name the files) instead of
  blanket `git add -A`; point verification/audit helpers at a temp dir **outside
  the repo**; and **re-confirm staging after a mixed delete + edit** (a staged
  deletion doesn't pull in an unstaged sibling edit). Kept in the adapter as a
  tool-mechanic, not in `core/`.
- **`core/02-RITUALS.md` — Ritual 5 (coherence pass)** gained a
  **Constraint-vs-behavior joint-satisfiability** lens: when an artifact settles
  *both* a hard constraint ("component / file X is off-limits / unchanged") and a
  behavior only X could deliver ("gate / alter / observe what X owns"), verify the
  two are *jointly satisfiable* — a seam delivers the behavior without touching X
  — before recording both as settled; an atomic operation exposing no hook can't
  satisfy both, so catch the contradiction at the spec, not three rounds later as
  an "impossible" task. Mirrored as a lens row in `core/03-REVIEW-GATES.md` §5;
  glossary entry added.
- **`core/04-LIFECYCLE.md` §2 (brainstorm/design stage)** — new **"Surface a
  request's hidden forks before building"** discipline: an *analogy-driven*
  request ("build it like X") can conceal a fork in the underlying *mechanism*
  where the branches differ materially (configuration, threat/security surface) —
  surface the fork with its trade-offs as an owner decision rather than picking
  one by inference; and a *"remove / simplify X"* request can hide a load-bearing
  shared **backbone** X merely rides on (X may be a *mode of* the backbone, not
  its replacement) — separate the surface feature from the backbone and confirm
  the backbone stays before specifying removals ("remove the X integration" ≠
  "remove the system X plugs into"). Tied to recommend-don't-decide (Principle 5);
  the removal-backbone trap is also echoed in `core/02-RITUALS.md` Ritual 5's
  *Premise vs reality* lens.
- **`core/04-LIFECYCLE.md` §1 (green baseline)** — sharpened the "kill stray
  processes" guidance with **process-provenance**: killing strays isn't enough —
  confirm a running server's command path belongs to *this* checkout before
  trusting it as "the app" (a leftover server from another or archived checkout
  can hold the canonical ports, and you can nearly verify against the wrong
  codebase), and detect environment surfaces by a **stable URL path, not a
  hardcoded port** (a port can be squatted by an unrelated process). Echoed in the
  completion ritual's *operational sanity* lens (`core/04-LIFECYCLE.md` §4 and
  `core/02-RITUALS.md` Ritual 1).
- **`core/02-RITUALS.md` — Ritual 5 (coherence pass)** gained an
  **Identifier-boundary footprint** lens: for a rename or split-identifier
  change, enumerate the *full* cross-boundary footprint — redirects/routes,
  build/container files, CI, root scripts, every consumer that filters on the old
  value — not just the definition site; an exact-match boundary breaks silently
  and a path-keyed tool can show clean while consumers break. Mirrored as a lens
  row in `core/03-REVIEW-GATES.md` §5; glossary entry added.
- **`core/02-RITUALS.md` — Ritual 7 (test-effectiveness)** gained a
  **harness-unobservable guarantees** lens: properties a hermetic harness
  force-disables or cannot observe (origin/CSRF rejection, a top-level redirect,
  real content-type handling, cross-origin cookies) get their *configuration*
  asserted in tests while the *end-to-end* proof is explicitly routed to live
  verification (Ritual 6) — a green hermetic suite is not evidence for a
  guarantee it structurally cannot exercise. A one-line cross-reference was added
  to Ritual 6.
- **`core/02-RITUALS.md` — Ritual 12 (lessons-learned capture)** gained a
  **promotion step**: a cross-cutting lesson (one that will recur in sibling
  tasks) is promoted from the dated session log into a standing **carry-forward
  checklist** referenced at the NEXT-STEPS resume cursor, so the next task
  inherits the warning instead of rediscovering it. Promotion path also noted in
  `core/01-DOC-MODEL.md` §7 and `core/04-LIFECYCLE.md` §5; glossary entry added.
- **`core/02-RITUALS.md` — Ritual 13 (parallel-work synchronization)** sharpened
  the "disjoint files only" rule: before dispatching parallel writers, enumerate
  each task's *entire* file footprint (not just its "primary" file), and
  serialize any two whose footprints might touch the same file — a clean merge
  from overlapping edits is luck, not safety.
- **`core/04-LIFECYCLE.md` §6 (Guardrails)** — new **Provision before you
  reference** guardrail: every referenced resource exists before its reference is
  evaluated; an aggregated secret/config bundle is all-or-nothing (one missing
  key fails the whole unit and every consumer); each value is injected into the
  component that actually consumes it; a migration/bootstrap entrypoint depends
  on the minimum, not the whole app config. Provisioning order is hardening, not
  an afterthought — nodded to under `core/00-PHILOSOPHY.md` Principle 2.
- **`core/01-DOC-MODEL.md` §2** — new **borrowed reference = mechanism, not
  identity** clause near the stable-ID / provenance guardrail: when building on a
  borrowed reference implementation or scaffold, separate reusable *mechanism*
  from *identity/design* (anchored on this project's own artifacts and
  version-control provenance); an inherited naming prefix carried in shared
  scaffolding is a non-signal — never infer identity from it.
- **`core/02-RITUALS.md` — Ritual 1 (completion ritual)** sharpened with two
  bolded clarifications: (a) **a passed task/artifact gate is NOT a sealed
  completion** — "done" is earned only by the multi-round completion sweep, run
  proactively before any done/seal/hand-off/reset; per-artifact reviews *feed* it,
  never *substitute* for it; (b) **inbound claims get the same evidence bar as your
  own** — a defect/risk claim you *receive* is verified against live code with
  file-and-line evidence before acting, and refuting the headline isn't the end:
  check the adjacent config/layer the reporter may actually mean (often the true
  exposure).
- **`core/02-RITUALS.md` — Ritual 5 (coherence pass)** gained a **Premise vs
  reality** lens (every "existing behavior" premise — a feature labelled
  dead/mock/redundant, an assumed harness, an inherited "current state" — is
  re-verified against live code; a label is a hypothesis, not a fact) and a **"a
  fix is itself a new change"** note (after a gate-driven fix, re-verify it against
  the source of truth *and* re-grep the whole doc funnel for the corrected fact, so
  a sibling artifact doesn't keep carrying the now-wrong value).
- **`core/03-REVIEW-GATES.md` — CLEAN is severity-defined, not zero-findings.**
  The findings-ledger subsection now defines how a finding becomes open-vs-
  dispositioned: tag every finding `blocker · major · minor`; a blocker/major is an
  open finding that FAILs the round and resets the streak, a minor is dispositioned
  by the agent running the gate (accept / defer to BACKLOG / fold in) and does not by itself reset
  it — so a CLEAN round is "no new *open* finding," not "zero findings." Unifies
  with the existing "no new open finding" rule (severity is *how* a finding becomes
  open). Also adds **"A fix is itself a new change"** (re-verify the fix vs live
  code + re-grep the funnel for the corrected fact before the round counts clean)
  and refreshes the §8 quick reference (`CLEAN`, `FIX`, severity in `LEDGER`).
- **`core/03-REVIEW-GATES.md`** — made the review-gate engine safe to run as a
  *parallel swarm* without weakening the cadence:
  - New **"Breadth within a round, depth across rounds"** — parallelism is K
    reviewers *within* one round (distinct lenses, one frozen snapshot; the round
    is CLEAN only if every reviewer is clean), while the clean-streak still counts
    *serialized* rounds. Collapsing N rounds into one big fan-out is called out as
    a cadence violation, so the floor + two-consecutive-clean exit hold bit-for-bit.
  - New **"The findings ledger"** — a shared `open · fixed · wontfix` ledger handed
    to each fresh reviewer ("report only NEW findings"), the missing precondition
    that stops a parallel, no-memory review loop from oscillating and never
    converging.
  - Quick-reference updated with the `PARALLEL` and `LEDGER` lines.
- **`adapters/claude-code/hooks/`** — the Ritual-12 SessionEnd snapshot now writes to
  `.harness/memory-snapshots/` (was `.keel/snapshots/`) and prunes to the newest 20;
  the hook install recipe is now array-safe (concatenates the `PostToolUse`/`SessionEnd`
  arrays instead of letting `jq *` replace them).

## [0.1.0] — Initial release

The first portable, generalized cut of the framework.

### Added

- **`core/`** — the tool-agnostic methodology:
  - `00-PHILOSOPHY.md` — the durable principles.
  - `01-DOC-MODEL.md` — the documentation funnel + anti-drift discipline.
  - `02-RITUALS.md` — the standing rituals.
  - `03-REVIEW-GATES.md` — the convergence cadence (the gate engine).
  - `04-LIFECYCLE.md` — the loop every change runs through.
  - `05-GLOSSARY.md` — definitions for every Keel term.
- **`templates/`** — fill-in skeletons (placeholders + guidance only):
  - `docs/` — README, BACKLOG, ROADMAP, NEXT-STEPS, PRD, PROJECT_RULES,
    STACK_WIRING, AS-BUILT-FOR-QA, and the `guides/` + `lessons-learned/` indexes.
  - `spec-and-plan/` — SPEC and PLAN skeletons.
- **`adapters/claude-code/`** — the first tool adapter: maps the core rituals onto
  concrete agent mechanics (independent reviewers, parallel fan-out, durable
  cross-session notes, hooks).
- **`bootstrap/init.sh`** — a portable installer: copies the funnel (and optionally
  the adapter) into a target project, strips `.tmpl`, substitutes placeholders, is
  idempotent-safe (never overwrites without `--force`), and prints a post-install
  checklist. Helpers in `bootstrap/lib/`.
- **`examples/`** — a fully-populated toy funnel (a URL shortener) showing what
  filled-in Keel docs look like end to end.
- Repo glue: `README.md`, `LICENSE` (MIT), `.gitignore`, this changelog.

[0.3.0]: #030--2026-07-01
[0.2.0]: #020--2026-06-30
[0.1.0]: #010--initial-release
