---
name: tdd
description: >
  Test-driven development with a red-green loop. Use when the user wants to
  build features or fix bugs test-first, mentions "red-green-refactor", or
  explicitly wants TDD / integration tests first. Not the default for this
  profile — default coding style prefers tests after code unless this skill
  (or implement driving TDD) is active.
license: MIT
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle — consult them before and during the loop, not after.

**Opt-in:** This profile's always-on instructions prefer tests written *after* the code for ordinary work. Follow **this** skill when the user (or `implement`) explicitly wants red-green.

When exploring the codebase, read `CONTEXT.md` (if it exists) so test names and public-surface vocabulary match the project's domain language, and respect ADRs in the area you're touching. Prefer the **codebase-design** vocabulary: seams are public surfaces over plain data + free functions — not class hierarchies or virtual interfaces.

## What a good test is

Tests verify behavior through **public surfaces**, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification — "user can checkout with valid cart" tells you exactly what capability exists — and survives refactors because it doesn't care about internal structure.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Seams — where tests go

A **seam** is the public boundary you test at: the surface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything — agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

Ask: "What's the public surface, and which seams should we test?"

## Anti-patterns

- **Implementation-coupled** — mocks internal collaborators, tests private helpers, or verifies through a side channel (querying the database instead of using the public surface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological** — the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth — a known-good literal, a worked example, the spec.
- **Horizontal slicing** — writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior. Work in **vertical slices** instead — one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.
- **Clean-Code ceremony** — do not force class/interface hierarchies, "one assert per tiny method," or mock-everything-internal. Prefer batch/data-oriented public surfaces when that matches the codebase.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to the review stage (see the `code-review` skill), not the red → green implementation cycle. Optional follow-up: `ponytail-review` for complexity.

---

Source: https://github.com/mattpocock/skills (skills/engineering/tdd) — MIT.
Adapted: opt-in vs always-on tests-after; public-surface / DOD language; no class hierarchy pressure.
