# Keelwright examples

A worked, **fully-populated** Keelwright doc funnel for a tiny toy project — so you can
see what the [`templates/`](../templates/) look like once filled, before you fill
your own.

> Everything here is **illustrative fiction**. The toy is a "Tinyl" URL shortener.
> The dates, file paths, test counts, and decisions are invented to demonstrate
> shape and tone — copy the *structure*, not the content.

---

## What's here

```
examples/
└── url-shortener/
    └── docs/
        ├── README.md       ← the front door (source-of-truth map + current cursor)
        ├── BACKLOG.md      ← the parking lot (ID-stable ideas + deferrals)
        ├── ROADMAP.md      ← the plan (milestones + what shipped)
        ├── NEXT-STEPS.md   ← the live resume cursor + paste-ready resume prompt
        └── PRD.md          ← what the system IS today (as-built)
```

It is a minimal **one-feature** project (shorten a URL, redirect on visit) so the
funnel stays readable end to end. Real projects have more docs (PROJECT_RULES,
STACK_WIRING, specs/plans, lessons-learned) — see the full set in
[`../templates/`](../templates/).

---

## How to read it

Follow the funnel left-to-right, the way knowledge actually flows:

1. **[`BACKLOG.md`](url-shortener/docs/BACKLOG.md)** — every idea and deferral,
   each with a permanent `BL-NNN` ID. Note `BL-001` is `done` (promoted + shipped),
   `BL-002` is `in-progress` (promoted to M2, still in flight), and `BL-005` is
   `dropped` (kept for the trail). IDs are never reused.
2. **[`ROADMAP.md`](url-shortener/docs/ROADMAP.md)** — the backlog items that were
   chosen, sequenced into milestones, with an honest record of what shipped and
   what was deferred (by ID — never restated).
3. **[`NEXT-STEPS.md`](url-shortener/docs/NEXT-STEPS.md)** — §1 is the single
   source of resume truth: where work is *right now*, the green baseline, and a
   paste-ready resume prompt a cold session can use verbatim.
4. **[`PRD.md`](url-shortener/docs/PRD.md)** — the as-built reality: what the
   system does today, with honest status badges and deferrals pointing back to the
   backlog by ID.
5. **[`README.md`](url-shortener/docs/README.md)** — the front door that routes a
   cold reader to all of the above in one hop.

Watch how a single item travels the funnel: **custom alias** enters as `BL-002`,
gets promoted to milestone M2 on the ROADMAP, and is the in-flight cursor in
NEXT-STEPS — currently landing as `FR4` (◑ in flight) in the PRD. Once M2 ships,
its backlog row flips to `done` and `FR4` to ✅; the already-shipped core feature
`BL-001`/`FR1` shows that end state today. That one item, one canonical home at
each stage, referenced elsewhere by ID — is the anti-drift discipline in action
([`../core/01-DOC-MODEL.md`](../core/01-DOC-MODEL.md)).

---

## Generate your own

This example was hand-filled to read well. To scaffold the **blank** version for a
real project, run `keel init` in it (interactive, like `git init`):

```sh
cd /path/to/your/project
keel init
```

Or non-interactively / from CI:

```sh
keel init /path/to/your/project --yes --name "Your Project" --slug your-project
```

Then fill the placeholders — using this example as a reference for tone and depth.
