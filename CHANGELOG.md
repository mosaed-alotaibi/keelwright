# Changelog

All notable changes to Keel are recorded here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[0.1.0]: #010--initial-release
