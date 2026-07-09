---
name: writing-great-skills
description: >
  Reference for writing and editing agent skills well — vocabulary and
  principles that make a skill predictable. Use when authoring or revising
  SKILL.md files in this Copilot config or any skills library.
license: MIT
---

A skill exists to wrangle determinism out of a stochastic system.
**Predictability** — the agent taking the same _process_ every run, not
producing the same output — is the root virtue; every lever below serves it.

**Bold terms** are defined in [`GLOSSARY.md`](GLOSSARY.md); look them up there
for the full meaning.

## Invocation (this profile)

In this VS Code / GitHub Copilot skills layout, each skill is a folder with
`SKILL.md` whose YAML frontmatter includes at least **`name`** and
**`description`**. The description is how the agent discovers when to load the
skill — write rich trigger phrasing ("Use when the user wants…, mentions…").

- Prefer **model-discoverable** descriptions for skills the agent should reach
  for on its own.
- Keep descriptions short; every word is **context load**.
- Do **not** rely on `disable-model-invocation` or other host-specific keys
  unless you have verified they work in the current VS Code Copilot loader.
  If a skill should be human-only, say so in the description ("Only when the
  user explicitly asks for …") rather than unproven frontmatter.

When skills multiply past what you can remember, a small **router skill** or a
README catalog cures **cognitive load**. This repo uses the README catalog;
a router is optional.

## Writing the description

A **description** does two jobs — state what the skill is, and list the
**branches** that should trigger it:

- **Front-load the skill's leading word** where it helps invocation.
- **One trigger per branch.** Collapse synonym restatements of the same branch.
- **Cut identity that's already in the body.** Triggers + reach clauses only.

## Information hierarchy

A skill is built from **steps** and **reference**:

1. **In-skill step** — ordered action in `SKILL.md`. Each step ends on a
   **completion criterion** (checkable; exhaustive where it matters).
2. **In-skill reference** — definitions/rules consulted on demand.
3. **External reference** — sibling files (e.g. `GLOSSARY.md`) via a **context
   pointer**, loaded when the pointer fires.

**Progressive disclosure** moves reference down the ladder so the top stays
legible. Branching is the cleanest disclosure test: inline what every branch
needs; push behind a pointer what only some branches need.

**Co-location:** keep a concept's definition, rules, and caveats under one
heading.

## When to split

**Granularity** spends load — only split when the cut earns it:

- **By invocation** — distinct **leading word** / independent reach worth a
  separate always-visible description.
- **By sequence** — hide **post-completion steps** that cause **premature
  completion** (only when you observe the rush and the criterion is fuzzy).

## Pruning

- **Single source of truth** for each meaning.
- Check every line for **relevance**.
- Hunt **no-ops** sentence by sentence; delete whole sentences that fail.

## Leading words

A **leading word** is a compact pretrained concept the agent thinks with
(_tight_ loop, _red_ on the bug, _tracer bullets_). Collapse restated triads
into one strong token where you can.

## Failure modes

- **Premature completion** — end a step early; sharpen the completion criterion first.
- **Duplication** — same meaning in more than one place.
- **Sediment** — stale layers that never get removed.
- **Sprawl** — skill simply too long; disclose reference, split by branch/sequence.
- **No-op** — line the model already obeys by default.
- **Negation** — "don't do X" names X; prefer positive target behaviour.

## Layout in this repo

Skills live flattened under `User/prompts/skills/<name>/` with `SKILL.md` and
optional supporting files. Always-on style lives in
`User/prompts/copilot-instructions.md`, not in every skill.

---

Source: https://github.com/mattpocock/skills (skills/productivity/writing-great-skills) — MIT.
Adapted: VS Code Copilot frontmatter realities; no unverified disable-model-invocation.
