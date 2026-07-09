# Plan: Integrate mattpocock/skills + ponytail into this Copilot config

## Overview

Vendor selected **MIT-licensed** skills from
[mattpocock/skills](https://github.com/mattpocock/skills) and
[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) into this
repo (which mirrors the VS Code `User/` profile directory). Ponytail's "laziness
ladder" is delivered **both** as an always-on nudge in `copilot-instructions.md`
and as invokable skills. Where a source conflicts with the existing
data-oriented / hand-roll instructions, it is **adapted**, not copied verbatim.

Both upstreams are MIT, so vendoring with attribution is clean.

Status: **plan only — do not implement until instructed.**

---

## Sources & licenses

| Upstream | License | What we take |
|----------|---------|--------------|
| `mattpocock/skills` | MIT | `diagnosing-bugs`, `code-review`, `research`, `writing-great-skills`, `handoff`, `codebase-design` (heavily adapted) |
| `DietrichGebert/ponytail` | MIT | `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt` + always-on ladder |

Attribution: each ported skill keeps `license: MIT` + a `source:` URL in its
frontmatter, plus a Credits section in the README.

---

## Current repo facts

- `User/prompts/copilot-instructions.md` — always-on (`applyTo: "**"`).
  Data-oriented design, procedural, performance-first, anti-over-engineering.
- `User/prompts/skills/<name>/SKILL.md` — the skill loader path. Frontmatter
  requires `name` + `description`. `grill-with-docs` is already vendored here
  (flattened — no `engineering/` or `productivity/` category folder).
- `beautiful-code.md` — 20 slop-vs-lean Odin reference examples.
- `README.md` — repo readme (edit target for the skills catalog + credits).
- Workflow: edit repo files, then sync `User/` → the VS Code profile and reload.

---

## Key adaptation — the ladder tension

Ponytail's ladder says *"stdlib does it → use it"* and *"installed dependency
solves it → use it."* The existing instructions say *"hand-rolling is usually
fine; a dependency is code you don't control,"* while allowing builtins like
crypto and serialization. Both agree on rejecting **new** dependencies.

**Resolution — adapt the ladder to the hand-roll stance:**

1. Does this need to exist at all? → no: skip it (**YAGNI**)  *(keep verbatim)*
2. Already in this codebase? → reuse it  *(keep verbatim)*
3. Stdlib / builtin does it? → use it  *(keep — matches "builtins like crypto & serialization are fine")*
4. Native platform feature covers it? → use it  *(keep verbatim)*
5. **Adapted:** an *already-vendored* dependency solves it → use it. **Default:
   do not add a *new* dependency** — prefer hand-rolling a small custom piece.
   Exceptions (already in the house instructions): stdlib/builtins and small
   focused battle-tested packages you can't realistically beat (crypto /
   serialization class), or when you explicitly ask.
6. Can it be one line? → one line  *(subject to the § conflict order: not if that
   one line is the wrong/flimsier algorithm)*
7. Only then: the minimum that works  *(keep verbatim)*

Keep the `ponytail:` shortcut-comment marker (a deliberate simplification whose
comment names the ceiling + upgrade path) — it fits the existing "comment the
*why*, not the *what*" rule.

---

## Key adaptation 2 — "boring over clever" vs `beautiful-code.md`

> Adopted from `grok_plan.md` §4.1 — the most important gap it caught.

Ponytail's rules include *"boring over clever,"* *"deletion over addition,"* and
*"shortest working diff wins."* Read literally, these collide head-on with
`beautiful-code.md`, which **celebrates** clever representation-level tricks
(fast inverse sqrt, Morton encode, branchless masks, closed-form decay). Left
unreconciled, an agent could cite ponytail to reject a legitimate hot-path
optimization — the exact opposite of the house style.

**House rule — authoritative conflict order (author-confirmed):**

1. Correctness / safety / trust-boundary validation / data-loss handling.
2. **Real performance of the work that matters** — hot-path and algorithmic
   wins (may be "clever": bit tricks, SoA, branchless, closed-form) when they
   pay for themselves.
3. Fewest lines / fewest files / no unrequested abstraction (ponytail).
4. Clever *without* measurable or structural advantage → reject as slop (see
   `beautiful-code.md` #15, the XOR swap).

So "boring over clever" means **no clever abstractions without payoff** — it
never overrides a real performance gain, and comments explaining non-obvious
performance intent are expected, not a smell. This ordering is embedded into the
always-on ladder section (Layer 1) and restated as a house-rule block inside the
`ponytail` skill so the two never drift apart.

---

## What to port

### Ponytail (adapted)
- **Always-on:** a compact "laziness ladder" section (~12 lines) added to
  `copilot-instructions.md`, reusing the existing "Avoid over-engineering /
  Don't abstract early" voice so it reads as one document.
- **Skills:** `ponytail` (ladder + `lite`/`full`/`ultra` intensity, **embeds the
  house-rule block + DOD non-negotiables**), `ponytail-review` (diff →
  over-engineering delete-list, **and the DOD inverse: flag code that is "lean"
  but cache-hostile / representation-naive / wrong data layout**), `ponytail-audit`
  (repo-wide over-engineering audit), `ponytail-debt` (harvest `ponytail:`
  shortcut comments into a ledger).

### mattpocock (adapt cross-references)
- `diagnosing-bugs` — reproduce → minimise → hypothesise → instrument → fix →
  regression-test. Fits the "tests for tricky/critical logic" stance.
- `code-review` — two-axis review (Standards + Spec) via parallel sub-agents.
  **Standards baseline is DOD-primary: `copilot-instructions.md` +
  `beautiful-code.md`.** Fowler smells only as a heavily-filtered secondary
  (real duplication of non-trivial logic, dead code); **never** flag long
  procedural functions, free-function modules, or switch-on-union. Spec axis
  unchanged. *Optional third axis:* a **Complexity** pass routed through
  `ponytail-review`.
- `research` — investigate against primary sources, capture a cited Markdown
  file.
- `writing-great-skills` — authoring reference (useful since this repo *is* a
  skills library).
- `handoff` — compact a conversation into a handoff document.
- `codebase-design` — **heavily adapted**: reframe "deep modules" as a small
  public surface over **plain data + free functions**; strip all class /
  interface hierarchy framing. Phase B.

---

## What to skip (and why)

- `tdd` — test-first, conflicts with the "tests written *after* the code" stance.
- `to-spec`, `to-tickets`, `implement`, `triage`, `wayfinder`,
  `setup-matt-pocock-skills` — issue-tracker pipeline; too much machinery.
- `ask-matt` — router over skills we are not fully porting.
- `ponytail-gain`, `ponytail-help` — benchmark scoreboard / command list; low
  value here.
- `grill-me`, `grilling`, `domain-modeling`,
  `improve-codebase-architecture`, `prototype`, `teach` — optional later;
  `grill-with-docs` already covers the grilling loop.

---

## File-by-file plan

| # | File | Action | Phase |
|---|------|--------|-------|
| 1 | `User/prompts/copilot-instructions.md` | Adapted ladder (~12 lines, soft-default rung 5) + § conflict order | A |
| 2 | `User/prompts/skills/ponytail/SKILL.md` | Adapted ladder; house-rule block (DOD + conflict order); `lite/full/ultra`; `argument-hint`; MIT + source | A |
| 3 | `User/prompts/skills/ponytail-review/SKILL.md` | Over-engineering delete-list **+ DOD inverse** (lean-but-cache-hostile / wrong layout) | A |
| 4 | `User/prompts/skills/diagnosing-bugs/SKILL.md` (+ support) | Port + adapt; strip dangling refs | A |
| 5 | `User/prompts/skills/handoff/SKILL.md` | Port + adapt | A |
| 6 | `User/prompts/skills/code-review/SKILL.md` | Port; **DOD-primary Standards**; Fowler heavily filtered; optional complexity pass | B |
| 7 | `User/prompts/skills/research/SKILL.md` | Port + light VS Code adaptation | B |
| 8 | `User/prompts/skills/writing-great-skills/SKILL.md` | Port (+ glossary if present) | B |
| 9 | `User/prompts/skills/codebase-design/SKILL.md` | Port **heavily adapted** — plain data + free functions; strip class/interface framing | B |
| 10 | `README.md` | Skills catalog + Credits (MIT + URLs) | A/B |
| 11 | `beautiful-code.md` | Fix stale companion path (`.github/…` → `User/prompts/…`) | A |
| — | `ponytail-audit`, `ponytail-debt` | **Deferred fast-follow** (repo-wide audit / `ponytail:` ledger) | later |

---

## Porting method

1. Shallow-clone both MIT repos to a temp dir to get exact source files (avoids
   transcription errors and captures each skill's supporting files).
2. Copy each selected skill folder wholesale, **flattened** directly under
   `User/prompts/skills/<name>/` (matching `grill-with-docs`).
3. Apply the ladder adaptation and strip dangling references to un-ported skills
   so every ported skill is self-contained.
4. Preserve MIT attribution.

**Phased rollout** (sequence by value / conflict risk, adopted from grok):

- **Phase A — high value, low conflict:** always-on ladder + house rule;
  `ponytail` + `ponytail-review`; `diagnosing-bugs`; `handoff`.
- **Phase B — workflow, no tracker lock-in:** `code-review` (DOD-primary
  Standards); `research`; `writing-great-skills`; `codebase-design` (heavily
  adapted).
- **Deferred fast-follow (after core proves out):** `ponytail-audit`,
  `ponytail-debt`. Still optional/skip: `ask-skills` router; `grill-with-docs`
  refresh/split.

---

## Verification

1. Each new `SKILL.md` frontmatter validates against the `grill-with-docs`
   reference (has `name` + `description`).
2. Grep the skills dir for dangling references and expect **zero**: `/tdd`,
   `/to-spec`, `/to-tickets`, `/implement`, `/triage`, `/grill-me`, `ask-matt`,
   `issue tracker`, `/ponytail-gain`, `/ponytail-help`.
3. Confirm the ponytail skill + always-on ladder match the soft-default
   dependency rule (no absolute "never a new dep") and don't contradict the
   conflict order.
4. Confirm `codebase-design` contains **no** class/interface-hierarchy guidance —
   the DOD reframe (plain data + free functions) is complete.
5. Sync `User/` → profile, reload, confirm the new skills appear in the skill
   list (as `grill-with-docs` already does); README renders; licenses present.

---

## Cross-review with `grok_plan.md`

### Insights adopted from grok

- **Boring-vs-clever house rule + conflict order** (grok §4.1) — the single
  biggest addition; see "Key adaptation 2". Closes a real gap between ponytail's
  minimalism and `beautiful-code.md`'s performance tricks.
- **DOD-aware `ponytail-review`** — also flag the *inverse* defect: few-line
  code that is cache-hostile or representation-naive.
- **`beautiful-code.md` companion-path check** — its header cites
  `.github/copilot-instructions.md`; in this repo the file is at
  `User/prompts/copilot-instructions.md`. Verify intent; fix if stale.
- **Phased rollout (A/B/C)** — sequence by value and conflict risk.
- **`code-review` optional third "complexity" axis** via `ponytail-review`.
- **`grill-with-docs` is the older monolithic form** — upstream v1.1.0 splits it
  into `grilling` + `domain-modeling` + a thin wrapper. Noted as an option only.

### Where I diverge / call-outs on grok's plan

- **Do not split `grill-with-docs`.** Splitting into `grilling` +
  `domain-modeling` adds files and indirection for a personal profile — itself
  the premature abstraction the ladder argues against. Keep monolithic until a
  second skill genuinely needs to compose the pieces.
- **`disable-model-invocation: true` needs verification.** Grok proposes this
  frontmatter key; I have **not** confirmed it is a supported field in the VS
  Code skill loader (the observed format is just `name` + `description`). Verify
  against a known-good skill before use; do not ship an unverified key.
- **`ask-skills` router — weigh the maintenance cost.** A hand-maintained router
  must be updated every time the skill set changes and adds indirection. Keep it
  Phase C / optional, not core.
- **`implement` / `tdd` — skip, don't just defer.** Both presume the
  spec/ticket + TDD-default flow that conflicts with "tests after code." I lean
  toward not porting them at all rather than importing as "opt-in later."
- **Retain `research` + `writing-great-skills`.** Grok effectively drops both;
  `writing-great-skills` is worth keeping because this repo *is* a skills
  library, and `research` earns its place for primary-source investigation.

---

## Decisions (defaults — change any on request)

- **Scope:** port all requested skills; ponytail delivered as always-on nudge
  **and** skills. Skip `tdd`, the issue-tracker pipeline, and
  `ponytail-gain`/`ponytail-help`.
- **Boring vs clever:** locked to the house-rule conflict order above
  (author-confirmed) — real performance wins outrank ponytail minimalism;
  clever-without-payoff is still rejected.
- **Keep `grill-with-docs` monolithic** (no split) until composition is needed.
- **Ladder adaptation:** keep YAGNI → reuse → stdlib/builtin → native verbatim;
  rung 5 = *"use an already-vendored dep; default no **new** dep; prefer
  hand-rolling — but stdlib/builtins + focused battle-tested packages are fine,
  and a new dep is OK on explicit request."* Keep the `ponytail:` marker.
- **Attribution:** per-skill `license: MIT` + `source:` frontmatter, plus a
  README Credits section.

---

## Resolved via interview (2026-07-09)

1. **Dependency rung 5 →** soft default — prefer hand-roll; stdlib/builtins +
   focused battle-tested packages (crypto / serialization class) OK; a **new**
   dep only on explicit request or the unbeatable-package case. Not an absolute
   "never."
2. **`code-review` Standards →** DOD-primary (`copilot-instructions.md` +
   `beautiful-code.md`); Fowler only as a heavily-filtered secondary.
3. **First pass →** Phase A + B; `ponytail-audit` / `ponytail-debt` deferred to a
   fast-follow after the core proves out.
4. **`codebase-design` →** port now in Phase B, heavily adapted to plain data +
   free functions (no class/interface hierarchies).
5. **Confirmed:** `ask-skills` router deferred (revisit only if discoverability
   hurts); Copilot CLI plugin/hooks out of scope for v1 (copy-`User/` model);
   `grill-with-docs` stays monolithic.

**Plan is locked. Awaiting your go-ahead to implement (Phase A + B).**
