# PRD — Tinyl

**Status:** Living — reflects the **as-built** system.
**Last updated:** 2026-03-12 — M1 (core shorten + redirect) shipped; M2 (alias) in flight.
**Owner:** Jordan Lee

<!-- This is a TOY example. Content is illustrative fiction. -->

> **Scope of this document.** The consolidated, *current* PRD: what Tinyl **is
> today**. Companion docs: [`ROADMAP.md`](ROADMAP.md) (plan + history),
> [`NEXT-STEPS.md`](NEXT-STEPS.md) (resume runbook), [`BACKLOG.md`](BACKLOG.md)
> (parking lot). Status badges: ✅ done · ◑ partial · ⛔ deferred.

---

## 1. TL;DR

Tinyl is a tiny anonymous URL shortener. A caller `POST`s a long URL and gets back
a short code; anyone visiting `/<code>` is `302`-redirected to the original URL.
The one defining constraint: it is **single-tenant and anonymous** — no accounts,
no per-user data. Proof it works: `POST /shorten` then `GET /<code>` redirects,
verified live and by 18 passing tests.

## 2. Problem & users

People paste long, ugly URLs into chats and slides. **Primary user:** anyone with a
link to share. **Deployment target:** single-tenant, single small service; anonymous.

## 3. Goals

| # | Goal | Status |
|---|---|---|
| G1 | Shorten any valid http(s) URL to a compact code | ✅ |
| G2 | Redirect a known code to its original URL fast | ✅ |
| G3 | Let callers pick a custom alias | ◑ (M2 in flight — BL-002) |
| G4 | Report per-link click counts | ⛔ deferred (M3 — BL-003) |

## 4. Architecture (as built)

```
Client (curl / browser)            ── issues POST /shorten and GET /:code
   │  HTTP
   ▼
Service — HTTP server (:8080)      ── validate URL, generate code, store, redirect
   │   in-process call
   ▼
Store — in-memory map (default)    ── code → original URL  (swappable for a DB)
```

The store holds `code → { url }` records. There is no separate datastore process by
default; the in-memory map is the resting-mode store (see [`NEXT-STEPS.md`](NEXT-STEPS.md) §4).

## 5. Functional requirements (implemented)

### 5.1 Shortening
- **FR1 — Create short link** (`POST /shorten`): validates the URL is http(s),
  generates a 6-char code, stores `code → url`, returns `{ "code": "..." }`.
- **FR2 — Reject invalid URLs** (`POST /shorten`): a non-http(s) or malformed URL
  returns `400` with an error body.

### 5.2 Redirecting
- **FR3 — Redirect by code** (`GET /:code`): a known code `302`-redirects to its
  original URL; an unknown code returns `404`.

### 5.3 Custom alias
- **FR4 — Caller-chosen alias** (`POST /shorten` with `alias=`) *(◑ in flight — M2,
  BL-002; see §9)*: accepts a charset-checked alias; a taken alias returns `409`.

## 6. Non-functional requirements

| # | Requirement | Status |
|---|---|---|
| NFR1 | Redirect responds in < 10 ms (in-memory store) | ✅ |
| NFR2 | Codes are collision-resistant within one run | ◑ (random 6-char; no cross-restart guarantee — in-memory) |
| NFR3 | No PII stored (anonymous by design) | ✅ |

## 7. Data / integrations (current)

- **Link store** — in-memory map, process-local. Auth: none (single service).
  Access: read-write. Swappable for a persistent datastore behind the same store API.

## 8. Success metrics (as built)

- **North star:** a shared short link resolves to the right destination 100% of the
  time. **Actual:** 18/18 tests + live shorten→redirect pass.
- **M1 deliverable gate:** create + redirect both work end to end — passed 2026-02-28.

## 9. Future improvements (deferred — the roadmap)

> Prioritization & milestone framing live in [`ROADMAP.md`](ROADMAP.md); item detail
> lives in [`BACKLOG.md`](BACKLOG.md) by ID. This table is the capability catalog.

| Area | Improvement | Trigger / notes |
|---|---|---|
| Alias | Custom alias (BL-002) | In flight (M2). |
| Analytics | Per-link click counts (BL-003) | M3; pairs with rate-limit (BL-006) for honest counts. |
| Lifecycle | Link expiry / TTL (BL-004) | When self-destructing links are requested. |

## 10. Out of scope (today)

User accounts/login (deliberately anonymous — see BACKLOG "Not backlogged"); vanity
domains (dropped — BL-005); multi-tenancy.

## 11. Source-of-truth map

The canonical doc map lives in [`README.md`](README.md). This PRD is canonical for
**current as-built requirements**; [`ROADMAP.md`](ROADMAP.md) for the plan + history;
[`NEXT-STEPS.md`](NEXT-STEPS.md) for resume state; [`BACKLOG.md`](BACKLOG.md) for the parking lot.
