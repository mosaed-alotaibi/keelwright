# Keel — Documentation Model & Anti-Drift Discipline

> The canonical home for how Keel projects organize their docs. This file *is*
> the doc-model; every other doc points **here** rather than re-describing the
> funnel (obeying its own guardrail — see #2 below).
>
> One sentence: **docs form a funnel, each fact has exactly one home, IDs are
> permanent, and one map routes everyone in.**

---

## 1. The funnel

Project knowledge flows left-to-right through four canonical docs. Each answers a
different question; each feeds the next.

```
  BACKLOG  ───▶  ROADMAP  ───▶  NEXT-STEPS  ───▶  PRD
  ideas /        the plan        how to           what the
  deferrals      (milestones      resume          system IS
  (parking lot)   + history)     (the cursor)     (as-built)
```

| Stage | Question it answers | Time horizon | Owner mindset |
|---|---|---|---|
| **BACKLOG** | "What might we do, and what did we deliberately *not* do?" | Future / parked | A parking lot. Ideas, deferrals, and honestly-recorded removals. Nothing here is committed. |
| **ROADMAP** | "What's the plan, and what has shipped?" | Past + planned | Milestones and their history. Promoted from the backlog; demoted to history when done. |
| **NEXT-STEPS** | "If I start right now, where exactly do I begin?" | Present | The live **resume cursor** — the single most current pointer. Re-read [`04-LIFECYCLE.md`](04-LIFECYCLE.md) §5. |
| **PRD** | "What does the system actually do today?" | As-built present | The contract / as-built requirements. Describes reality, not intent. |

**Flow of an item through the funnel:** an idea enters BACKLOG with a stable ID →
when chosen, it's promoted to a ROADMAP milestone → while in flight, NEXT-STEPS
holds the live cursor for it → when shipped, ROADMAP records it as history and PRD
describes the resulting behavior. The backlog item is then marked `done` (never
deleted — see #3).

---

## 2. Anti-drift: the two guardrails

Drift is when two docs disagree about the same fact. Two rules prevent it.

### Guardrail A — One canonical location per item

Each fact, decision, or item lives in **exactly one** authoritative doc. Every
other mention **references it by ID** and never restates the detail.

- *Why:* a fact in two places is a fact that will eventually disagree with itself. Single-home means a change has exactly one edit site.
- *In practice:* the source-of-truth map (#4) assigns one canonical doc per concern. If you're about to copy a detail into a second doc, link to its ID instead.
- *Self-application:* this file is the canonical home for the doc-model, so the front-door map points **here** rather than re-explaining the funnel.

### Guardrail B — Stable IDs, never reused or renumbered

Every backlog item carries a permanent ID (e.g. `BL-001`, `BL-002`, …).
Requirements and milestones keep their identifiers for life.

- *Why:* cross-references (Guardrail A) only survive if the thing they point to keeps its name. Renumbering silently breaks every reference.
- *Rules:* IDs are assigned once and **never** reused or renumbered. A dropped item keeps its ID with status `dropped` — the ID is retired, not recycled. New items always take the next free number.

---

## 3. Backlog schema

The backlog is a flat, ID-stable table. Suggested columns:

| Field | Values | Notes |
|---|---|---|
| **ID** | `BL-NNN` | Permanent. Never reused or renumbered. |
| **Title** | short phrase | What it is. |
| **Type** | `feature` · `enhancement` · `removed-deferred` | `removed-deferred` records something taken *out* (honesty about what was cut). |
| **Status** | `parked` · `planned` · `in-progress` · `done` · `dropped` | A `done`/`dropped` item stays in the table — history, not deletion. |
| **Why** | one line | The rationale (why parked, why removed). |
| **Future context** | one line | What it'd take to revive / how to think about it later. |
| **Source / links** | refs | Where it came from (a spec, a review, a session note). |

The canonical backlog is a doc *we* own — committed to version control, one home
per item. Do not delegate it to a tool-generated or transient backlog (see
[`00-PHILOSOPHY.md`](00-PHILOSOPHY.md) #9 → *tool-owned state*): a tool may track
its own working list, but the authoritative, ID-stable record is **this** doc.

Record **intentional non-items** too: if something was removed *and deliberately
not backlogged*, say so in a note — silence reads as an oversight, and an absent
item with no explanation invites someone to "helpfully" re-add it.

---

## 4. The source-of-truth map

One — and only one — doc holds the master map of *which doc owns which concern*.
This is the project's front door. It assigns a single canonical home per concern
so Guardrail A has something to enforce against.

| Concern | Canonical doc |
|---|---|
| Project onboarding / how to run | the top-level README |
| Docs index + this very map | the docs front-door README |
| Ideas / deferrals (the parking lot) | BACKLOG |
| The plan (milestones + history) | ROADMAP |
| How to resume / what's next | NEXT-STEPS |
| What the system is (as-built) | PRD |
| The doc model itself (this funnel) | this file |
| Standing engineering rules | the project rules / rituals doc |
| Per-session lessons learned | the lessons-learned directory |
| History / superseded docs | the archive directory (with its own index) |
| Component-specific docs | live *with the component*, not in the central docs |

> Adapt the rows to your project — the discipline is "**one row per concern, one
> doc per row, no doc duplicates another's concern**," not this exact list.

---

## 5. The front-door README

A reader arriving cold — a fresh agent session, a new teammate — should reach the
right current information in **one hop**. The front-door README is that hop. It
contains, at minimum:

1. **Start here** — a short "fresh context" block pointing at the live NEXT-STEPS cursor (and nothing stale).
2. **The source-of-truth map** (#4).
3. **How the docs connect** — the diagram below.

The front-door README **routes**; it does not duplicate. It links to the canonical
docs; it never restates their content (Guardrail A).

---

## 6. How the docs connect

```
  README  ── front door: source-of-truth map + "start here"
    │
    ├──▶  BACKLOG ──────  ideas / deferrals (ID-stable parking lot)
    ├──▶  ROADMAP ──────  the plan (milestones + history)
    ├──▶  NEXT-STEPS ───  the live resume cursor  ◀── always current
    ├──▶  PRD ──────────  what the system is (as-built)
    ├──▶  RULES ────────  standing engineering rules / rituals
    ├──▶  lessons/ ─────  per-session issues + mitigations + lessons
    ├──▶  archive/ ─────  history / superseded (its own index)
    └──▶  <component>/ ─  module docs live with their module
```

---

## 7. Keeping the funnel honest

Anti-drift is not a one-time setup — it's a standing discipline that pairs with
two ideas elsewhere in Keel:

- **State-change currency** ([`02-RITUALS.md`](02-RITUALS.md) §10): right after any action that changes durable state (a merge, a ship, a deferral, a branch), sweep the front-door docs and cross-session notes for claims the change just falsified, and fix them *before ending the turn*. Prefer **drift-proof phrasing** ("check the current state via `<command>`") over hardcoded facts that re-stale on the next change.
- **Leave history alone:** dated artifacts — the archive, past specs/plans, "why" notes — describe *past* state and stay as-is. Only the *living* front-door docs and *current-state* notes get reconciled. History is a record, not a thing to keep current.

The test of a healthy doc model: **a cold reader, given only the front-door README,
lands on the current cursor and nothing stale.** If they land on a shipped
milestone announced as "active," the funnel has drifted — fix it.
