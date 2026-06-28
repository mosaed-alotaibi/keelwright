# Project Docs — Tinyl

**Open this first** — the docs front door + source-of-truth map.

<!-- This is a TOY example. Content is illustrative fiction. It includes only the
     core funnel docs (BACKLOG/ROADMAP/NEXT-STEPS/PRD + this README) to stay
     readable; a real project also keeps PROJECT_RULES, STACK_WIRING, specs/plans,
     lessons-learned, etc. — see ../../../templates/. Rows for docs not present in
     this minimal example are marked "(not in this example)". -->

---

## Start here (fresh context)

> **▶ CURRENT (2026-03-12):** M2 — Custom alias (BL-002), in execution at Task 3 of 5.
> **Authoritative current cursor = [NEXT-STEPS.md](NEXT-STEPS.md) §1.**

---

## The source-of-truth map

This is the **one** canonical map — one doc per concern. No other doc duplicates it.

| Concern | Canonical doc |
|---|---|
| How to resume / what's next | [`NEXT-STEPS.md`](NEXT-STEPS.md) |
| The plan (milestones + history) | [`ROADMAP.md`](ROADMAP.md) |
| Ideas / deferrals (parking lot) | [`BACKLOG.md`](BACKLOG.md) |
| What the system is (as-built reqs) | [`PRD.md`](PRD.md) |
| Docs index + this map | `README.md` |
| Standing engineering rules | `PROJECT_RULES.md` *(not in this minimal example)* |
| Designs / specs + plans | `spec-and-plan/` *(not in this minimal example)* |

---

## How the docs connect

```
docs/README.md ─ you are here (front door + source-of-truth map)
   │
   ├─▶ BACKLOG.md ──── ideas / deferrals (parking lot: BL-001 … BL-006)
   ├─▶ NEXT-STEPS.md ── §1 = authoritative current cursor (always up to date)
   ├─▶ ROADMAP.md ───── the plan (M1 shipped · M2 in flight · M3 planned)
   └─▶ PRD.md ───────── what the system is (FR1 … FR4)
```

The docs form a funnel: **BACKLOG → ROADMAP → NEXT-STEPS → PRD** (ideas/deferrals →
the plan → how-to-resume → as-built). Each fact lives in exactly one canonical doc;
every other mention references it by ID and never restates the detail.

**Trace one item through the funnel:** custom alias is `BL-002` in BACKLOG → milestone
M2 in ROADMAP → the live cursor in NEXT-STEPS §1 → `FR4` (◑ in flight) in PRD. One
home per stage; every other mention is a reference by ID.
