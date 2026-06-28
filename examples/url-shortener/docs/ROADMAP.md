# Roadmap — Tinyl

> New here? Open the [docs index](README.md) first, then the resume runbook
> [`NEXT-STEPS.md`](NEXT-STEPS.md).
> **Last updated:** 2026-03-12 — M2 (custom alias) in flight; M1 shipped.
> **Authoritative current cursor = [`NEXT-STEPS.md` §1](NEXT-STEPS.md).**
> **Plan owner:** Jordan Lee.

<!-- This is a TOY example. Content is illustrative fiction. -->

This is the **current plan**. It owns the *order* of work and the honest record of
what shipped; item detail lives once in [`BACKLOG.md`](BACKLOG.md) by ID.

## 1. What shipped (Delivered)

As-built detail: [`PRD.md`](PRD.md).

| Milestone | What | State |
|---|---|---|
| **M1 — Core shorten + redirect** | `POST /shorten` returns a short code; `GET /:code` 302-redirects to the original URL (BL-001). | ✅ 18/18 tests green; live-verified end to end (create → redirect). |

## 2. Planned milestones (the real plan)

- **M2 — Custom alias** *(status: IN-PROGRESS; on branch `feature/custom-alias`)*.
  Let a caller pass a chosen short code (BL-002); reject collisions with `409`.
  Spec + plan: `spec-and-plan/SPEC.md` · `spec-and-plan/PLAN.md` <!-- a real project keeps these; omitted from this minimal example -->.
  - **Kept / clarified:** alias charset limited to `[a-z0-9-]`, 3–32 chars.
  - **Added:** a `409 Conflict` path the core flow never had.
- **M3 — Click analytics** *(status: PLANNED)*. Per-link visit counts (BL-003);
  `GET /stats/:code`. Couples with BL-006 (rate-limit) for honest counts under abuse.

### 2.1 Removed / Deferred record — M2

| What was removed | Destination |
|---|---|
| Link expiry from the alias milestone | → **BL-004** (parked — landed too broad for M2) |
| Vanity domains | **NOT backlogged — intentional** (dropped: needs multi-tenant we won't build; see BL-005) |

**Kept (not removed):** the collision-rejection behavior — it is M2's whole point.

## 3. Reprioritized backlog (re-framed)

| Item | New status |
|---|---|
| Rate-limit shorten (BL-006) | **DEPLOYMENT-DRIVEN** — only matters once the create endpoint is public; revisit with M3 analytics so counts stay honest. |

## 4. How we work

Every change goes through the proven loop and the standing rules — a real project
keeps these in `PROJECT_RULES.md` (the lifecycle loop, review gate, and seal ritual;
omitted from this minimal example). Resume via [`NEXT-STEPS.md`](NEXT-STEPS.md).
