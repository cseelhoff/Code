---
name: research
description: >
  Investigate a question against high-trust primary sources and capture findings
  as a cited Markdown file. Use when the user wants a topic researched, docs or
  API facts gathered, or reading legwork delegated.
license: MIT
---

# Research

Investigate the user's question against **primary sources** — official docs,
source code, specs, first-party APIs — not secondary write-ups. Follow every
claim back to the source that owns it.

## How to run

1. If the host supports a **background / parallel sub-agent**, spin one up for
   the research so the main thread can keep working. If not, do the research
   **inline** in this session — same quality bar.
2. Investigate against primary sources only. Prefer official documentation,
   RFCs, language/stdlib references, and the actual source of libraries.
3. Write findings to a **single Markdown file**, with citations for each claim
   (URL and/or path + version when known).
4. Save where the repo already keeps such notes; match existing convention. If
   none, use something sensible (e.g. `docs/research/<slug>.md` or
   `.scratch/research/<slug>.md`) and tell the user the path.
5. End with a short "open questions / confidence" section when sources conflict
   or coverage is incomplete.

## Quality bar

- No claim without a cite.
- Prefer primary over blog posts; if only secondary exists, label it secondary.
- Record versions / dates of docs when APIs drift often.
- Do not invent APIs or behaviour — if unknown, say unknown.

---

Source: https://github.com/mattpocock/skills (skills/engineering/research) — MIT.
Adapted: works with or without background agents (VS Code Copilot-friendly).
