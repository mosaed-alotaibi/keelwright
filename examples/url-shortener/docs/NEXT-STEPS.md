# Next steps — how to resume safely and what's next

> Durable runbook for resuming after a context reset. Authoritative for "what's next
> + how to start without breaking what we've done." Pairs with the standing rules
> (`PROJECT_RULES.md` in a real project; omitted from this minimal example). The live
> contract is the code + [`PRD.md`](PRD.md); older handoffs are archived under `archive/`.
> **Last updated:** 2026-03-12 — M2 in execution at Task 3; the §1 cursor is authoritative.

<!-- This is a TOY example. Content is illustrative fiction. -->

---

## 1. Where we are (the current cursor — do NOT break this)

> **▶ CURRENT INITIATIVE (2026-03-12) — M2: Custom alias (BL-002).**
> GOAL: let a caller pass a chosen short code, rejecting collisions with `409`.
> STATE: IN-EXECUTION — spec + plan converged; executing the plan, on Task 3 of 5.
>
> **Audited maturity / readiness:** core shorten/redirect 100% (M1 shipped) · alias
> create-path ~70% · collision-rejection ~40% (tests written, handler stubbed).
> Current gates: unit tests green (18/18 from M1, +4 new red as expected for the
> stubbed handler); live-verify of the 409 path still OPEN.
>
> **Workstreams / open gaps (evidence-backed):**
> - **A · alias validation** — charset/length guard in `src/validate.js`; done, tested.
> - **B · collision rejection** — `src/store.js insertAlias()` returns a stub; the
>   `409` path in `src/routes.js` is not yet wired (see PLAN Task 3).
> - **C · live verification** — no captured evidence yet that a duplicate alias 409s.
>
> **Locked architecture / decisions (do not relitigate):** alias charset
> `[a-z0-9-]`, 3–32 chars; collisions are a hard `409` (never silently re-key).

**▶ NEXT ACTION (who owns it):** wire the `409 Conflict` path in `src/routes.js`
per PLAN Task 3, then live-verify a duplicate-alias request returns 409 — owner: the implementer.

> **✅ DONE — M1: Core shorten + redirect** *(branch `main`, shipped 2026-02-28)*:
> `POST /shorten` → short code; `GET /:code` → 302. 18/18 tests; live-verified.
> **⚠ HISTORICAL** — "M1 in flight at Task 4" (true when written; superseded by the live cursor above).

**▶ RESUME PROMPT — paste in a clean session to continue this initiative:**

```
RESUME — Tinyl: M2 Custom alias (BL-002).
Repo: ./tinyl. Follow PROJECT_RULES.md; durable notes auto-load (see the adapter for your agent).

GOAL: accept a caller-chosen short code; reject collisions with 409.
TODAY: spec + plan converged; executing the plan at Task 3 (wire the 409 path). M1 shipped on main.

EXECUTE: continue the plan at Task 3.

FIRST READ (in order): NEXT-STEPS.md §1 (this cursor) → spec-and-plan/SPEC.md → spec-and-plan/PLAN.md → src/routes.js.

WORKSTREAMS: A alias-validation (done) · B collision-409 (in progress) · C live-verify (open).
LOCKED DECISIONS: alias charset [a-z0-9-], 3–32 chars; collisions = hard 409.
PEOPLE/CONSTRAINTS: owner Jordan Lee holds merge/push; implementer drives the plan.

FIRST STEP: open src/routes.js, wire insertAlias() failure → 409, then run the alias tests.
```

## 2. Milestone history (condensed)

M1 (core shorten + redirect) shipped 2026-02-28 on `main` — see ROADMAP §1. M2
(custom alias) opened 2026-03-08 on `feature/custom-alias`.

## 3. The proven loop (how every change is made)

`brainstorm` (get owner approval) → **spec** → **plan** → execute (fresh implementer
per task + independent review) → **verify live** → **re-run the full gate matrix** →
**seal ritual** (two consecutive clean re-audit rounds) → commit per task → push.
See `PROJECT_RULES.md` (kept in a real project; omitted from this minimal example).

## 4. Establish the GREEN BASELINE before touching anything (the safety net)

```
npm install                        # deps; expected: no errors
npm test                           # expect 18/18 green  <- M1 known-good line
node src/server.js &               # boots on :8080
curl -s -XPOST localhost:8080/shorten -d url=https://example.com   # expects {"code":"..."}
curl -s -i localhost:8080/<code>   # expects: HTTP/1.1 302, Location: https://example.com
```

If shorten → redirect works end to end, **that's your known-good line** — any later
difference is your change, not a mystery.

> **Resting mode (2026-03-12):** in-memory store by default (no DB to boot). Tests
> always run against the in-memory store regardless of local config — keep it the
> hermetic test default.

## 5. Guardrails (non-negotiable)

- **Branch convention** — feature work off `main` as `feature/*`; merge only by owner.
- **Additive + tested.** Don't regress the 18 M1 tests or the shorten→redirect behavior.
- **The 4 new alias tests are red on purpose** until Task 3 lands — that's expected,
  NOT a regression. Don't "fix" them by weakening the assertions.
- **Push/merge only what the owner approves.** Stop and confirm at the seal ritual.

## 6. Paste-ready resume prompt (full template)

> The §1 block is the LIVE resume prompt; this section is the reusable shape for the
> *next* initiative. Keep superseded prompts below, marked HISTORICAL, for the trail.

> **⚠ HISTORICAL resume prompts** — none yet; M2 is the first post-M1 initiative.
