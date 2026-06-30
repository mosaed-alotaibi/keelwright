# scripts/ — placeholder

Keelwright ships **no** headless-browser driver: stacks vary too much for one to be portable.
The driver belongs in **your project's** `scripts/` directory (run from your project root),
not here. This file exists only so the directory is tracked and the intent is documented.

For ritual 6 (live render / verify) you add, in your own repo:

- a **"drive one real turn + screenshot"** helper (boot the stack, perform a real
  interaction, capture a screenshot), and
- a **"navigate to route + screenshot"** helper.

Use whatever headless-browser tooling fits your `{{WEB_FRAMEWORK}}` (CDP, Playwright,
Puppeteer, etc.). See [`../README.md`](../README.md) install step 5 and
[`../rules/RITUALS-IN-CLAUDE-CODE.md`](../rules/RITUALS-IN-CLAUDE-CODE.md) ritual 6.
