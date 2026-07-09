---
name: implement
description: >
  Implement a piece of work based on a spec, set of tickets, or the current
  conversation. Use when the user says implement, build this ticket/spec, or
  wants a full build → review closeout.
license: MIT
---

# Implement

Implement the work described by the user in the spec, tickets, or conversation.

## Process

1. **Understand the work.** Read the spec/ticket(s), domain glossary (`CONTEXT.md`), and relevant ADRs. If the issue tracker config is missing and the ticket lives on a tracker, run or point the user at `setup-matt-pocock-skills`.

2. **Agree seams for tests.** Prefer existing public surfaces. List seams you will exercise and confirm with the user when non-obvious.

3. **Build with `tdd` where possible**, at those **pre-agreed** seams (red → green vertical slices). If the user declines TDD for this task, implement first and add focused tests after on critical paths — matching always-on house style.

4. **Check as you go.** Run typechecking regularly, single test files regularly, and the full test suite once at the end (when a suite exists).

5. **Review.** Run `code-review` on the diff since the branch point (or another fixed point the user names). Optionally run `ponytail-review` for over-engineering / layout issues.

6. **Commit** to the current branch when the user wants a commit (follow repo commit norms; do not force-push or skip hooks unless asked).

Clear context between tickets when working a frontier from `to-tickets` / wayfinder.

---

Source: https://github.com/mattpocock/skills (skills/engineering/implement) — MIT.
Adapted: optional tests-after path; local skill names; optional ponytail-review.
