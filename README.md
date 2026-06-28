# Keel

> A portable, generalized development framework: the durable methodology of a
> mature software project, stripped of project specifics and reusable on any
> codebase, by any AI coding agent **or** a human team.

Keel is not a tool you run. It is a **methodology you adopt** — a lifecycle loop,
a set of review gates, a documentation funnel, and a handful of standing rituals
that together make "are we done?" answerable instead of vibes-based. The core is
deliberately tool-agnostic; a thin adapter maps it onto whatever agent or
toolchain you actually use.

---

## What Keel gives you

| You get | Where it lives |
|---|---|
| A loop every change runs through (brainstorm → spec → plan → execute → verify → seal) | [`core/04-LIFECYCLE.md`](core/04-LIFECYCLE.md) |
| Review gates that must run dry before you stop (min 3 rounds, exit on 2 consecutive clean) | [`core/03-REVIEW-GATES.md`](core/03-REVIEW-GATES.md) |
| Standing rituals (completion, verification, anti-drift, lessons-learned, …) | [`core/02-RITUALS.md`](core/02-RITUALS.md) |
| A documentation funnel that resists drift (BACKLOG → ROADMAP → NEXT-STEPS → PRD) | [`core/01-DOC-MODEL.md`](core/01-DOC-MODEL.md) |
| The principles underneath it all | [`core/00-PHILOSOPHY.md`](core/00-PHILOSOPHY.md) |
| Fill-in doc/spec/plan skeletons | [`templates/`](templates/) |
| A concrete mapping onto one agent | [`adapters/claude-code/`](adapters/claude-code/) |
| A one-command installer | [`bootstrap/init.sh`](bootstrap/init.sh) |
| A worked, populated example funnel | [`examples/`](examples/) |

---

## The three layers

Keel is organized so the durable methodology never tangles with any one tool. Each
layer has a single, strict job.

```
keel/
├── core/        TOOL-AGNOSTIC methodology — the durable "what" and "why".
│                Reads sensibly for ANY AI coding agent OR a human team.
│                No tool names. This is the source of truth.
│
├── templates/   FILL-IN skeletons — the docs/specs/plans a project keeps.
│                Pure placeholders ({{PROJECT_NAME}} …) + guidance comments,
│                zero real content. init.sh copies + fills these.
│
├── adapters/    TOOL-SPECIFIC mappings — the concrete "how" for one agent.
│   └── claude-code/   Maps the core rituals onto real mechanics (independent
│                      reviewers, fan-out, durable cross-session notes, hooks).
│
├── bootstrap/   init.sh — installs the funnel (+ optional adapter) into a project.
└── examples/    A tiny, fully-populated funnel so you can see the end state.
```

| Layer | Contains | Never contains |
|---|---|---|
| **`core/`** | The methodology: principles, doc model, rituals, gates, lifecycle, glossary. | Any specific tool's name or mechanics. |
| **`templates/`** | Skeletons with `{{PLACEHOLDERS}}` and `<!-- guidance -->`. | Real project content. |
| **`adapters/<agent>/`** | The literal moves for one agent/toolchain. | Methodology decisions (those live in core). |

**The rule of thumb:** if it's a principle, it goes in `core/`. If it's a blank to
fill, it goes in `templates/`. If it names a specific tool, it goes in
`adapters/`.

---

## 60-second quickstart — apply Keel to a new project

```sh
# From anywhere. Point init.sh at the project you want to adopt Keel.
keel/bootstrap/init.sh /path/to/your/project \
  --name "Your Project" \
  --slug your-project \
  --with-cc-adapter            # omit if you're not using the Claude Code adapter
```

That single command:

1. copies the doc funnel into `your-project/docs/` (BACKLOG, ROADMAP, NEXT-STEPS,
   PRD, PROJECT_RULES, and the supporting docs), stripping the `.tmpl` suffix;
2. copies the spec + plan skeletons into `your-project/docs/spec-and-plan/`;
3. substitutes the placeholders it knows (`{{PROJECT_NAME}}`, `{{PROJECT_SLUG}}`,
   `{{OWNER}}`, `{{DATE}}`, …);
4. optionally installs the Claude Code adapter (`CLAUDE.md`, memory seeds, a hook
   snippet to merge);
5. refuses to overwrite anything that already exists (pass `--force` to override),
   and prints a post-install checklist of the placeholders you still need to fill.

Then open `your-project/docs/NEXT-STEPS.md`, fill in the current cursor, and start
the loop. Full installer usage: `keel/bootstrap/init.sh --help`.

> **Want to see the destination before you start?** [`examples/`](examples/) holds
> a complete, filled-in funnel for a toy project — what a populated set of Keel
> docs actually looks like.

---

## Philosophy, in one paragraph

Move **quick where it's safe and cautious where mistakes cost real work — and
never claim what you haven't shown.** Evidence beats assertion: "done" is earned by
a verification you ran and surfaced, not declared. The author is their *own* first
reviewer — every artifact passes a self-review gate before the owner ever sees it,
and the owner keeps genuine veto only on the decisions that bind (merges, releases,
which goal to pursue). A working **and** hardened system beats a faster one, so
latent risk gets closed while the context is fresh — but scope stays tight, and you
generalize only once a second real case appears. Throughout, the written hand-off
is kept current enough that any session can end at any moment and a cold reader —
a fresh agent, a new teammate — can pick up without losing ground. The full
statement is in [`core/00-PHILOSOPHY.md`](core/00-PHILOSOPHY.md).

---

## Where to go next

- New to the ideas? Read [`core/00-PHILOSOPHY.md`](core/00-PHILOSOPHY.md), then
  [`core/04-LIFECYCLE.md`](core/04-LIFECYCLE.md).
- Adopting it? Run [`bootstrap/init.sh`](bootstrap/init.sh) and fill
  [`templates/`](templates/).
- Using Claude Code? Read [`adapters/claude-code/README.md`](adapters/claude-code/README.md).
- Unsure of a term? [`core/05-GLOSSARY.md`](core/05-GLOSSARY.md) defines them all.

---

Keel is intentionally small. Read it once; the discipline it encodes pays for the
hour. See [`CHANGELOG.md`](CHANGELOG.md) for versions and [`LICENSE`](LICENSE) for
terms.
