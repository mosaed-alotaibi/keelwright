# Contributing to Keelwright

Keelwright is small, opinionated, and meant to be improved. This guide is short on
purpose — like the framework itself.

The one thing to internalise first: **Keelwright is built with its own discipline.**
A change to the methodology goes through the same loop and gates the methodology
prescribes. If that feels recursive, good — it's the strongest test that the ideas
actually hold up. The canonical statement of the loop is
[`core/04-LIFECYCLE.md`](core/04-LIFECYCLE.md); the review cadence is
[`core/03-REVIEW-GATES.md`](core/03-REVIEW-GATES.md).

---

## Ways to contribute

| You want to… | Start here |
|---|---|
| Sharpen a principle, ritual, or gate | Edit the relevant file in [`core/`](core/). Keep it **tool-agnostic** — no tool names. |
| Add support for a new agent / toolchain | Copy [`adapters/claude-code/`](adapters/claude-code/) to `adapters/<your-agent>/` and remap. |
| Improve a doc/spec/plan skeleton | Edit [`templates/`](templates/). Placeholders + guidance only; never real content. |
| Improve onboarding (`keel init`) | Edit [`keel`](keel) and [`bootstrap/lib/`](bootstrap/lib/). |
| Fix a typo, link, or example | Anywhere — small PRs are very welcome. |

---

## The three-layer rule (don't cross the streams)

Every change belongs to exactly one layer. Mixing them is the most common way a PR
goes wrong:

- **`core/`** — the durable *what* and *why*. If it names a specific tool, it does
  **not** belong here. This is the source of truth; everything else maps onto it.
- **`templates/`** — fill-in skeletons. `{{PLACEHOLDERS}}` and `<!-- guidance -->`
  only, zero real project content.
- **`adapters/<agent>/`** — the literal *how* for one tool. Methodology decisions
  never live here; they live in `core/` and the adapter references them.

> If you change a placeholder token in a template (e.g. `{{KEELWRIGHT_CORE_PATH}}`),
> update **both** the template and the installer's substitution map in
> [`bootstrap/lib/install.sh`](bootstrap/lib/install.sh) — they must match exactly,
> or substitution silently no-ops. This is the "identifier-boundary footprint"
> ritual ([`core/02-RITUALS.md`](core/02-RITUALS.md), Ritual 5) applied to the repo
> itself.

---

## How changes flow (the methodology, applied here)

1. **Open an issue / brainstorm** for anything non-trivial — surface the fork before
   building.
2. **Make the change** in the right layer. Keep scope tight (YAGNI); generalize only
   when a second real case appears.
3. **Run the gate on your own work** before asking for review — a genuine coherence
   pass over what you changed. Re-verify every file/line you cite against the live
   tree, not memory.
4. **Show evidence, don't assert it.** If you touched `keel` or the installer, run it
   and paste the result (see below). "It works" without output isn't a claim we can
   merge on.
5. **Open a PR** with a commit log a stranger can follow.

---

## Working on the CLI

`keel` and the installer are pure POSIX-bash (portable across macOS/BSD and Linux —
no bash-4-only features, no GNU-only flags). Before sending a PR:

```sh
# Syntax-check everything
bash -n keel bootstrap/init.sh bootstrap/lib/common.sh bootstrap/lib/install.sh

# Optional but encouraged
shellcheck -S warning keel bootstrap/init.sh bootstrap/lib/*.sh

# Prove it end to end in a throwaway dir (writes nothing real)
keel init /tmp/kw-smoke --yes --name "Smoke Test" --with-cc-adapter --dry-run

# A real install you can inspect, then delete
keel init /tmp/kw-real --yes --name "Smoke Test" --with-cc-adapter
find /tmp/kw-real -type f ; rm -rf /tmp/kw-real
```

---

## Releasing (maintainers)

The version has **one canonical home**: the [`VERSION`](VERSION) file. `keel`, the
installer, and the `.keelwright/config` marker all read it. On release:

1. Bump [`VERSION`](VERSION).
2. Add a dated section to [`CHANGELOG.md`](CHANGELOG.md) (Keep-a-Changelog format).
3. Update **every** version string in [`README.md`](README.md) — the badge *and* the
   `keel init` banner shown in the quick-start example (`grep -n '0\.3\.0' README.md`
   finds them all).
4. Tag the release `vX.Y.Z`.

These four are mirrors of the same fact — update them in the same commit so they
can't drift.

---

## License

By contributing, you agree your contributions are licensed under the project's
[MIT License](LICENSE).
