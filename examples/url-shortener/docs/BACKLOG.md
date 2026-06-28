# Backlog — Tinyl

> **Human-owned · committed under `docs/` · ID-stable.** The parking lot for
> deferred ideas and honestly-recorded removals. Left end of the funnel
> (`BACKLOG → ROADMAP → NEXT-STEPS → PRD`).
>
> - One canonical location per item: each lives here once under a stable `BL-NNN`
>   ID. Other docs reference it **by ID** and never restate the detail. IDs are
>   never reused or renumbered.
> - A `done`/`dropped` item keeps its row — history, not deletion.
>
> **Schema:** ID · title · type (`feature` | `enhancement` | `removed-deferred`) ·
> status (`parked` | `planned` | `in-progress` | `done` | `dropped`) · why ·
> future-context · source/links.

<!-- This is a TOY example. Content is illustrative fiction. -->

| ID | Title | Type | Status | Why | Future context | Source |
|---|---|---|---|---|---|---|
| **BL-001** | Shorten a URL → return a short code | feature | done | The core value proposition. | Shipped in M1. | Founding sketch |
| **BL-002** | Custom alias (user-chosen short code) | feature | in-progress | Power users want memorable links. | Add a `alias` field; reject collisions with a 409. | User interview notes |
| **BL-003** | Click analytics (per-link visit count) | feature | planned | Owners want to know if a link is used. | Increment a counter on redirect; expose `GET /stats/:code`. | Roadmap M3 |
| **BL-004** | Link expiry (TTL) | enhancement | parked | Some links should self-destruct. | Add `expires_at`; sweep on read; 410 when expired. | Support request |
| **BL-005** | Vanity domains (per-tenant custom domain) | feature | dropped | Out of scope for a single-tenant toy; needs multi-tenant routing + cert mgmt we won't build here. | Revisit only if the project goes multi-tenant. | Scoping review (dropped, kept for trail) |
| **BL-006** | Rate-limit the shorten endpoint | enhancement | parked | Prevent abuse of the public create endpoint. | Token-bucket per IP; return 429. Couples with BL-003 counters. | Security note |

> **Not backlogged (intentional):** a full user-accounts/login system. The toy is
> deliberately anonymous; recording it as `BL-NNN` would imply a revival path that
> doesn't exist. If accounts ever become real scope, open a fresh ID then.
