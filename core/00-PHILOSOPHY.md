# Keel — Philosophy

> The durable principles behind Keel. Tool-agnostic: they read the same whether
> your "agent" is an AI coding assistant, a second AI, or a human engineer.
> Everything else in Keel — the rituals, the doc model, the lifecycle loop —
> is machinery for living these principles. When a rule and a principle seem to
> conflict, the principle wins; the rule is wrong or out of date.

The mindset in one line: **quick where it's safe, cautious where mistakes cost
real work — and never claim what you haven't shown.**

---

## The principles

| # | Principle | Why it matters | How it shows up in Keel |
|---|---|---|---|
| 1 | **Evidence over claims** | "Done" asserted is not "done" verified; the gap between the two is where regressions hide. | Never say *done / fixed / clean / safe to reset* without running and **showing** the check in the same turn. Behavioral tests, live renders, queried state — not code-reading — are the proof. See [`04-LIFECYCLE.md`](04-LIFECYCLE.md), [`02-RITUALS.md`](02-RITUALS.md). |
| 2 | **Harden, don't defer** | A system that works *and* is hardened beats one that works *sooner*; latent risk closed while the context is fresh is far cheaper than a 2am incident later. | When in doubt, harden. Close the security/edge/failure path now rather than filing it. Make guarantees *literally* true, not aspirational. |
| 3 | **Generalize the durable principle** | A one-off fix solves today; the reusable abstraction solves the whole class. | Prefer the general mechanism over the special case — but only once the case is real (see #4). Extracted patterns become templates, adapters, rules. |
| 4 | **Tight scope (YAGNI)** | Speculative breadth is unpaid debt: more surface to test, document, and keep honest. | Build for the requirement in front of you. Don't add config, abstraction, or "while I'm here" features without a concrete need. Generalize (#3) only when a second real case appears. |
| 5 | **Recommend, don't decide** | The agent has the most context to *propose*; the owner must keep genuine go/no-go on the choices that bind. | The agent drives design → spec → plan → execution and reviews its own work to convergence. The **owner retains veto** only on reserved decisions: merges, pushes, releases, which goal to pursue, and genuine gray-area forks — never on routine review of work the agent already converged. |
| 6 | **The owner is the *second* reviewer, never the first** | If the owner is the first set of eyes, the agent has outsourced its own quality gate. | The agent runs its own coherence/review pass **before** surfacing any artifact, and states *what the pass checked and found*. The owner reads for visibility, not as the agent's first line of defense. |
| 7 | **Resume-safety: always keep a current handoff** | Any session can end at any moment; state that lives only in someone's head is lost on reset. | The "how to resume" doc and durable cross-session notes are kept current at every unit boundary, so a cold start — a fresh agent session, a new person — can pick up without losing ground. See [`04-LIFECYCLE.md`](04-LIFECYCLE.md) §5. |
| 8 | **Quick and cautious, both at once** | Ceremony for its own sake is waste; recklessness on irreversible actions is catastrophe. | Non-mutating actions (read, inspect, build, test, status) need no permission — just do them. Destructive or hard-to-reverse actions (data deletion, force operations, process kills) get confirmed first. Always trace a command's effect before running it. |
| 9 | **Tools own their state; we own ours** | Hand-editing a file a tool regenerates is at best futile, at worst silently corrupting. | Never hand-curate any tool-owned state directory or generated file. Keep the durable record where *we* own it: the docs, the version-control history, the cross-session notes. See [`05-GLOSSARY.md`](05-GLOSSARY.md) → *tool-owned state*. |
| 10 | **Tests verify behavior, not internals** | A passing suite that asserts implementation details protects nothing a user cares about. | Derive tests from business/technical *claims*, at real surfaces. Periodically audit that the tests would actually fail if behavior broke — "N passed" is not proof of quality. See [`02-RITUALS.md`](02-RITUALS.md). |

---

## How the principles compose

- **#1 + #6 + #10** are one idea at three altitudes: *show evidence* (claims), *be your own first reviewer* (artifacts), *test real behavior* (code). The throughline is **don't trust your own assertion — produce the proof.**
- **#5 + #6** define the division of labor: the agent owns the *review gate*; the owner owns the *decision gate*. The agent never asks the owner to do the review it should have done; the owner is never bypassed on a binding decision.
- **#2 + #4** are in deliberate tension — *harden* pulls toward more, *tight scope* pulls toward less. Resolve it by altitude: harden the thing you're **already** building (its edges, its failures, its security); don't *expand* what you're building. Hardening the current surface is not scope creep; adding new surface is.
- **#7 + #9** keep the project resumable and drift-free: the handoff is always current, and the record lives where it won't be silently overwritten.

---

## What "good" looks like

A change is finished when, without being asked, you can show:

1. the behavior works, at its real surface, with evidence you produced (#1, #10);
2. its edges and failure paths are handled, not filed for later (#2);
3. nothing it touched left the docs or cross-session notes stale (#7);
4. it stayed inside the scope it set out to solve (#4);
5. you reviewed it yourself first and can say what that review found (#6);
6. the owner still holds every decision that was theirs to hold (#5).

Anything short of that is a draft, not a deliverable — say so honestly.
