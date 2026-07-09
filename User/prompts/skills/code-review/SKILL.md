---
name: code-review
description: >
  Review changes since a fixed point (commit, branch, tag, or merge-base) along
  Standards (profile + repo coding standards) and Spec (originating issue/PRD/
  conversation). Use when the user wants to review a branch, PR, WIP changes,
  or asks to "review since X". Optionally follow with ponytail-review for a
  pure complexity pass.
license: MIT
---

# Code Review

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to documented coding standards (DOD-primary)?
- **Spec** — does the code faithfully implement the originating issue / PRD / conversation?

Both axes should run as **parallel sub-agents** when the host supports that, so
they don't pollute each other's context; then aggregate. If parallel sub-agents
are unavailable, run both axes sequentially in separate passes without merging
criteria mid-pass.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag,
`main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Capture: `git diff <fixed-point>...HEAD` (three-dot vs merge-base) and
`git log <fixed-point>..HEAD --oneline`.

Confirm the fixed point resolves (`git rev-parse`) and the diff is non-empty
before deeper work.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue / PR references in commit messages (`#123`, `Closes #45`, etc.) — fetch
   via the workflow in `docs/agents/issue-tracker.md` when setup has been run
   (`setup-matt-pocock-skills`); otherwise use `gh`/`glab`/browser if available,
   or ask the user for the text/URL.
2. A path the user passed as an argument.
3. A PRD/spec file under `docs/`, `specs/`, or similar matching the branch or feature.
4. The current conversation if the work was specified only there.
5. If nothing is found, ask. If there is no spec, the **Spec** axis reports
   "no spec available" and is skipped for findings.

### 3. Identify the standards sources (DOD-primary)

**Primary (always apply when available):**

1. This profile's global style: coding instructions the agent is already under
   (data-oriented, procedural, performance-first, hand-roll preferred). When
   reviewing work that used this Copilot profile, that is the bar even if the
   target repo has no local standards file.
2. Target-repo files if present: `CODING_STANDARDS.md`, `CONTRIBUTING.md`,
   `.github/copilot-instructions.md`, `AGENTS.md`, project `CONTEXT.md` / ADRs.
3. `beautiful-code.md` (or equivalent) for representation-level / hot-path hunks.

**Repo overrides profile only where the repo explicitly documents a different
standard for that project.**

**Secondary — heavily filtered Fowler-style smells** (judgement calls only; never
hard violations). A documented standard always wins over a smell. **Never flag:**

- Long procedural functions that stay cohesive
- Free functions over plain data / "not enough classes"
- Tagged union + switch (or enum + switch) as "should be polymorphism"
- SoA, handles, bitsets, branchless hot loops that match house style
- Hand-rolled small code preferred over a new dependency

**May flag (only if real in the diff):**

- **Mysterious Name** — name doesn't reveal role → rename or redesign murky shape
- **Duplicated Code** — same non-trivial logic shape repeated → extract once if it earns its keep
- **Data Clumps** — same few fields always travel together → one named struct/type
- **Primitive Obsession** — primitive standing in for a domain concept that needs a distinct type
- **Shotgun Surgery** — one logical change forces scattered edits → gather what changes together
- **Divergent Change** — one module edited for several unrelated reasons → split by reason
- **Speculative Generality** — abstraction/hooks for needs the spec doesn't have → delete until real need
- **Dead / unused flexibility** — configs nobody sets, layers with one caller

Skip anything tooling already enforces (formatter, linter).

### 4. Run both axes

**Standards brief:** Report per file/hunk (a) hard violations of primary
standards (cite the rule); (b) secondary smell judgement calls (name + hunk).
Under ~400 words.

**Spec brief:** Report (a) missing or partial requirements; (b) scope creep;
(c) implemented-but-wrong. Quote the spec/conversation for each finding.
Under ~400 words. Skip if no spec.

### 5. Aggregate

Present under `## Standards` and `## Spec` headings. Do **not** merge or
rerank across axes. One-line summary: findings count per axis + worst issue
within each axis.

### Optional third pass

If the user wants complexity-only findings, or Standards is clean but the diff
still feels heavy, run **`ponytail-review`** on the same fixed point (do not
blend its tags into Standards mid-report).

## Why two axes

A change can pass one axis and fail the other:

- Follows every standard but implements the wrong thing → Standards pass, Spec fail.
- Does what was asked but breaks house/repo conventions → Spec pass, Standards fail.

---

Source: https://github.com/mattpocock/skills (skills/engineering/code-review) — MIT.
Adapted: DOD-primary Standards; no issue-tracker skill dependency; filtered smells;
optional `ponytail-review` complexity pass.
