# Changelog

All notable changes to Keel are recorded here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

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
