---
name: handoff
description: >
  Compact the current conversation into a handoff document for another agent
  or a fresh session to pick up. Use when the user says "handoff", needs to
  continue in a new chat, or the context window is full.
license: MIT
---

Write a handoff document summarising the current conversation so a fresh agent
can continue the work. Save to the temporary directory of the user's OS — not
the current workspace — unless the user asks for a path in the repo.

Include a **"suggested skills"** section naming only skills that exist in this
profile when relevant, for example:

- `grill-with-docs` — sharpen plan / domain language
- `ponytail` / `ponytail-review` — minimize or hunt over-engineering
- `diagnosing-bugs` — hard bug / perf regression
- `code-review` — standards + spec review of a diff
- `codebase-design` — deep-module vocabulary (data + free functions)
- `research` — primary-source investigation
- `writing-great-skills` — editing skills in this config repo

Do not duplicate content already captured in other artifacts (specs, plans,
ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information (API keys, passwords, personally identifiable
information).

If the user passed arguments, treat them as a description of what the next
session will focus on and tailor the doc accordingly.

---

Source: https://github.com/mattpocock/skills (skills/productivity/handoff) — MIT.
Adapted: suggested skills list matches this profile; no disable-model-invocation.
