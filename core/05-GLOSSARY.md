# Keelwright — Glossary

> Concise definitions of the Keelwright terms used across `core/`. Tool-agnostic:
> each term reads the same whether the actor is an AI coding agent, a second AI,
> or a human. Where a term has a concrete Keelwright mechanism, the relevant `core/`
> file is linked.

---

## Roles & actors

| Term | Definition |
|---|---|
| **Agent** | Whoever (or whatever) does the work: an AI coding assistant, a second AI, or a human engineer. Keelwright is written so every principle applies to all three. The agent also **orchestrates** a multi-round ritual — dispatching each round to an independent reviewer, applying the fixes a round surfaces, and deciding when the exit condition is met — and never delegates the *decision* to stop (it "orchestrates and **owns the review cadence**", [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md)). |
| **Owner** | The person who holds genuine go/no-go on binding decisions (merges, pushes, releases, which goal to pursue, and genuine gray-area forks). The owner is the *second* reviewer, never the first — see *recommend-don't-decide* and [`00-PHILOSOPHY.md`](00-PHILOSOPHY.md). |
| **Independent reviewer** | A reviewer working in a **fresh context** with no memory of how the work was produced — a separate agent session, a second AI, or a different person. The truest test of whether the *written* record stands on its own, because they can only see what was written down, not what's in the author's head. |
| **Single writer** | The rule that durable shared artifacts (rituals, doc updates, cross-session notes) are written by **one** actor at a time, to avoid lost updates when work is fanned out in parallel. |

---

## The lifecycle

| Term | Definition |
|---|---|
| **Green baseline** | The proven-sound starting point before any change: a clean working tree, the documented build / boot / run commands working **from a clean state**, the test suite passing (and *looked at*, not just an exit code), and the resume pointers routing to the project's current state. A change that regresses it is not done. Capturing it is step one of the loop. See [`04-LIFECYCLE.md`](04-LIFECYCLE.md) §1. |
| **Lifecycle loop** | The standard progression a unit of work moves through: **brainstorm → spec → plan → execution**. Each stage produces an artifact that gets its own review before the next stage begins. See [`04-LIFECYCLE.md`](04-LIFECYCLE.md). |
| **Artifact** | A concrete output of a lifecycle stage — a design, a spec, an implementation plan, an execution-approach decision. An in-discussion design counts as an artifact even before it's written to a file: it gets reviewed before it reaches the owner. |
| **Spec** | The design document: *what* we're building and *why*, with the decisions settled. |
| **Plan** | The implementation plan: the ordered, concrete steps to build what the spec describes, each verifiable. |
| **Execution-approach decision** | The choice of *how* to carry out a plan — inline, sequential independent reviewers, parallel fan-out, etc. It is itself an artifact and gets reviewed like one. |
| **Fan out** | To dispatch multiple independent reviewers/workers at once. Free for read-only exploration; for writing, only on **disjoint** work (non-overlapping files) — converging edits serialize to a single writer. |

---

## Quality gates & rituals

| Term | Definition |
|---|---|
| **Ritual** | A repeatable, defined quality gate that runs at a specific trigger and has an explicit exit condition. Rituals make "are we done?" answerable instead of vibes-based. See [`02-RITUALS.md`](02-RITUALS.md). |
| **Review gate** | The agent's own quality check on an artifact, run *before* surfacing it to the owner. "The agent owns the review gate" means the agent — not the owner — is responsible for catching issues first. |
| **Coherence pass** | A single, genuine adversarial review of one just-produced artifact, run immediately after producing it and before showing it to anyone. Its lenses: *drift vs. reality, backward-compatibility, no placeholders, internal/cross-artifact consistency, docs & notes currency.* The light early-catch gate that feeds the heavier convergence cadence and completion ritual. |
| **Convergence cadence** | The iterative self-review applied to each high-leverage artifact (spec, plan, execution-approach): run a **minimum of 3** review iterations and stop only when the **two most recent are both clean**. The first iteration is mandatory groundwork and doesn't count toward the exit. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §2. |
| **Convergence** | The state of having met a cadence's exit condition (e.g. floor met **and** two consecutive clean passes). On convergence, an artifact is approved *by default* and the agent proceeds — it does not pause to ask permission to continue. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §2. |
| **Iteration / round** | One genuine adversarial review pass. It either **finds an issue** (→ fix it; this iteration is a *fail*, and a fix **resets** the consecutive-clean streak) or **finds nothing needing change** (a *clean pass*). "Genuine" means a fresh look with a distinct lens emphasis — never a rubber-stamp of the prior round. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §1. |
| **Clean pass** | A review iteration that finds nothing needing change. Two *consecutive* clean passes (above the floor) is the universal exit condition for Keelwright's review rituals — until the *relief valve* opens. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §1–§2. |
| **Relief valve** | The cadence's anti-deadlock rule: from **round 6 onward**, a **single** clean round converges the gate (no consecutive pair required; a FAIL at round 6+ still needs a subsequent clean round). Exists because reviewer churn — each fresh lens surfacing something different, small, and new — can otherwise keep a stable artifact oscillating forever. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §2 (rule 5). |
| **Completion ritual** | (a.k.a. *seal ritual* / *pre-done confirmation ritual*) The heavyweight gate before any "done" milestone — sealing, merging, releasing, or resetting context. Run as **independent-reviewer rounds in fresh context** (≥3 rounds, exit on 2 consecutive clean; from round 6, see *Relief valve*), so the review also tests whether the written handoff is resume-ready. Distinct from the per-artifact coherence pass, which it builds on. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §4 (heavy gate) and [`02-RITUALS.md`](02-RITUALS.md). |
| **Claim gate** | The non-negotiable rule that you never *assert* "done / fixed / clean / safe to reset / in sync" without, in the **same turn and before the claim**, running and **showing** the verifying evidence. Asserting first and being asked to prove it later is a violation. The same bar applies to an **inbound** claim you *receive* (a defect/risk report from a person, tool, or other agent): verify it against the live code with concrete file-and-line evidence before acting on it. See [`02-RITUALS.md`](02-RITUALS.md) Ritual 1. |
| **Findings ledger** | The shared `open · fixed · wontfix` record (with each finding's **severity**) that a multi-round, fresh-context review loop hands to every new reviewer so they report only **new** issues — the precondition that stops a no-memory parallel loop from re-reporting known findings and oscillating forever. The single fixer updates it between rounds. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §6. |
| **Finding severity** | The `blocker · major · minor` tag on each review finding that decides whether it is **open**. A *blocker/major* is open — it FAILs the round and resets the clean streak until fixed; a *minor* is **dispositioned** by the agent running the gate (accept / defer to BACKLOG / fold in) and does not, by itself, reset the streak. Hence a **CLEAN** round means *no new open (blocker/major) finding* — **not** zero findings of any kind. See [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §6. |
| **Dependency-reality check** | The ritual of verifying an unfamiliar / fast-moving / post-knowledge-cutoff dependency's *real* behavior — error & return semantics, exact export paths, which helper wraps which behavior, current CLI/version — against the **installed package's** source and types (not prose docs or priors) **before** designing on it, then pinning the exact version. Treats a fast release cadence as a standing patch obligation. Distinct from *external-dependency feedback* (Ritual 11), which influences the owner of a component you can't change; this one is design-time correctness against any dependency. See [`02-RITUALS.md`](02-RITUALS.md) Ritual 16. |
| **Live eval bar** | The verification standard for *agent-behavioral* surfaces (anywhere an LLM decides the output): **≥20 live shots** through the real product path, graded against **ground truth the agent cannot see**, **≥95% to pass**, on a stack spawned from the branch under test, under a **pre-registered protocol** (shot list, tolerances, one retry per turn-level malfunction). One good turn is a sample, not evidence. See [`02-RITUALS.md`](02-RITUALS.md) Ritual 17. |
| **Premise vs reality** | A coherence-pass lens: every *existing-behavior* premise an artifact builds on (a feature labelled dead/mock/redundant, an assumed test harness, an inherited "current state") is treated as a **hypothesis to confirm against live code**, not a fact — because an unverified premise propagates its error into everything downstream. See [`02-RITUALS.md`](02-RITUALS.md) Ritual 5. |
| **Identifier-boundary footprint** | A coherence-pass lens for a **rename or split-identifier** change: the *full* set of surfaces that key on the identifier — redirects/routes, build/container files, pipeline/CI config, root scripts, and every downstream consumer that filters on the old value — not just the definition site. An **exact-match boundary** (a redirect off by one character) breaks with no error, and a **path-keyed tool** can report clean while consumers built on the old identifier break — so the whole footprint is enumerated and grepped before the rename counts done. See [`02-RITUALS.md`](02-RITUALS.md) Ritual 5 and [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §5. |
| **Constraint-vs-behavior joint-satisfiability** | A coherence-pass lens: when an artifact settles **both** a hard constraint (a component / file is off-limits or unchanged) **and** a behavior only that component could deliver (gate / alter / observe what it owns), the two are checked to be **jointly satisfiable** — a seam must exist that delivers the behavior *without* touching the constrained component — before both are recorded as settled. An **atomic operation that exposes no hook** can satisfy one half but not both; a spec that locks in the contradiction surfaces it as an "impossible" task rounds later. See [`02-RITUALS.md`](02-RITUALS.md) Ritual 5 and [`03-REVIEW-GATES.md`](03-REVIEW-GATES.md) §5. |

---

## Documentation & state

| Term | Definition |
|---|---|
| **Funnel** | The four canonical docs in flow order: **BACKLOG → ROADMAP → NEXT-STEPS → PRD** (ideas → the plan → how-to-resume → as-built). See [`01-DOC-MODEL.md`](01-DOC-MODEL.md). |
| **Source-of-truth map** | The single master table assigning **one canonical doc per concern**. Lives in the front-door README; nothing else duplicates it. |
| **Canonical location** | The single authoritative home for a given fact, decision, or item. Every other mention references it (by ID) and never restates the detail (anti-drift Guardrail A). |
| **Stable ID** | A permanent identifier (e.g. `BL-NNN`) assigned once and **never reused or renumbered**, so cross-references survive edits (anti-drift Guardrail B). A dropped item keeps its ID with status `dropped`. |
| **Resume cursor** | The single most-current pointer to "where exactly to start next," held in NEXT-STEPS. A cold reader follows it to resume without losing ground. |
| **Resume-safe handoff** | The continuously-maintained written state — the resume cursor plus durable cross-session notes — kept current enough that work can stop at *any* moment and be picked up cold. See [`04-LIFECYCLE.md`](04-LIFECYCLE.md) §5. |
| **Durable cross-session notes** | Persistent notes that outlive a single working session and carry forward what a fresh context must know (decisions, conventions, current state). The vehicle for resume-safety; the agent-specific mechanism lives in the adapters layer. |
| **Carry-forward checklist** | A standing list of **cross-cutting** lessons (gotchas that will recur in sibling tasks) **promoted** out of the dated lessons-learned log and referenced at the NEXT-STEPS resume cursor, so the next task **inherits** the warning instead of rediscovering it. The dated log entry stays as history; the checklist is the *living* copy a fresh context reads first. See [`02-RITUALS.md`](02-RITUALS.md) Ritual 12. |
| **Currency** | The property of a doc or note being *true right now* — not contradicted by recent state changes. |
| **Drift** | The failure of currency: two docs (or a doc and reality) disagreeing about the same fact. Anti-drift is the standing discipline that prevents it. |
| **State-change currency** | The rule that immediately after any action changing durable state (merge, release, deferral, branch), you reconcile the front-door docs and notes for now-false claims *before ending the turn*. |
| **Drift-proof phrasing** | Wording that won't re-stale on the next change — e.g. "check the current value via `<command>`" instead of pinning a number or hash that the next commit invalidates. |
| **Tool-owned state** | Files or directories a tool generates and controls on its own lifecycle. Never hand-curated — editing them is futile (the tool overwrites) or harmful (schema drift). The durable record goes where *we* own it instead. |

---

## Testing

| Term | Definition |
|---|---|
| **Behavioral test** | A test derived from a real business or technical *claim*, verifying behavior at a user- or system-facing surface — not an implementation detail. The kind Keelwright asks you to write. See [`02-RITUALS.md`](02-RITUALS.md). |
| **Test-effectiveness audit** | A periodic check that the tests you *have* would actually fail if the behavior they protect broke — i.e. they're not vacuous, over-mocked, or tautological. "N passed" is not, on its own, proof of quality. |
| **Live verification** | Confirming a user-facing or behavioral change actually works by **exercising it for real** (rendering the UI, driving the flow, querying the resulting state) and inspecting the *actual* result — never claiming it works from code-reading alone. |

---

## Cross-cutting

| Term | Definition |
|---|---|
| **Harden** | To close a latent risk — a security hole, an edge case, a failure path — *now*, while the context is fresh, rather than deferring it. A working **and** hardened system is the bar. |
| **Scope (tight / YAGNI)** | Building only for the requirement actually in front of you; not adding speculative breadth. Generalize only when a second real case appears. |
| **Reserved decision** | A decision the owner explicitly keeps: merges, pushes, releases, which goal to pursue, and genuine gray-area design forks. Everything else (artifact review, execution approach) the agent decides and the owner spot-checks. |
