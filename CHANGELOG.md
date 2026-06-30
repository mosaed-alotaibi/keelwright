# Changelog

All notable changes to Keel are recorded here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

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
