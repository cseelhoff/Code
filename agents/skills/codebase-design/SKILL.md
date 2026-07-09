---
name: codebase-design
description: >
  Shared vocabulary for designing deep modules as plain data plus free
  functions: small public surface, lots of behaviour behind it, clean seams,
  testable through that surface. Use when designing or improving a module's
  public surface, finding deepening opportunities, placing a seam, or making
  code more testable or AI-navigable.
license: MIT
---

# Codebase Design

Design **deep modules**: a lot of behaviour behind a **small public surface**,
placed at a clean **seam**, testable through that surface. Modules here are
**plain data + free functions** (or a small package of those) — not class
hierarchies, not interface-with-one-implementation ceremony.

Aim: **leverage** for callers, **locality** for maintainers, testability for
everyone — consistent with data-oriented / procedural house style.

## Glossary

Use these terms exactly. Consistent language is the point.

**Module** — anything with a public surface and an implementation. Scale-agnostic:
a function, a file of related procs, a package, or a tier-spanning slice.
_Avoid_: unit, component, service, "class" as the unit of design.

**Public surface (interface)** — everything a caller must know to use the module
correctly: function signatures, invariants, ordering constraints, error/sentinel
modes, required configuration, and performance characteristics. This is **not**
the TypeScript/`interface` keyword, not a vtable, not an abstract base class.
_Avoid_: API (too vague), signature alone (too narrow).

**Implementation** — what's inside a module. Distinct from **Adapter**: a thing
can be a small adapter with a large implementation (Postgres-backed store) or a
large adapter with a small implementation (in-memory fake). Reach for "adapter"
when the seam is the topic.

**Depth** — leverage at the public surface: behaviour a caller (or test) can
exercise per unit of surface they learn. **Deep** = large behaviour behind small
surface; **shallow** = surface nearly as complex as the implementation.

**Seam** _(Michael Feathers)_ — a place where you can alter behaviour without
editing at that place; the *location* of the public surface. Where the seam goes
is its own design decision. _Avoid_: boundary (overloaded with DDD bounded context).

**Adapter** — a concrete stand-in at a seam (e.g. another package of free
functions, a function pointer table, a different backend). Describes *role*, not
OOP substance. Prefer plain data in / plain data out.

**Leverage** — what callers get from depth: more capability per unit of surface.

**Locality** — what maintainers get: change, bugs, knowledge, and verification
concentrate in one place. Fix once, fixed everywhere.

## Deep vs shallow

**Deep module** = small public surface + lots of implementation:

```
┌─────────────────────┐
│  Small public surface│  ← Few entry points, simple params
├─────────────────────┤
│  Deep implementation │  ← Complex logic / layout hidden
└─────────────────────┘
```

**Shallow module** = large surface + little implementation (avoid): pass-through
wrappers, ceremony layers, one-liner "services".

When designing a surface, ask:

- Can I reduce the number of entry points?
- Can I simplify parameters (group data clumps into one struct)?
- Can I hide more complexity *and* better data layout inside?

## Principles

- **Depth is a property of the public surface, not line count inside.**
- **The deletion test.** Delete the module: if complexity vanishes, it was a
  pass-through; if it reappears across N callers, it earned its keep.
- **The public surface is the test surface.** Callers and tests cross the same
  seam. If you must test *past* it, the shape is probably wrong.
- **One adapter means a hypothetical seam. Two adapters means a real one.**
  Don't introduce a seam until something actually varies (e.g. prod backend +
  in-memory test double).
- **Polymorphism here** means tagged union + switch or data-driven tables — not
  virtual dispatch or class hierarchies.
- **Pass dependencies explicitly** as parameters (function values, handles,
  buffers) — don't construct hidden globals inside the module.

## Designing for testability

1. **Accept collaborators as parameters; don't construct them inside.**

   ```
   // Testable — payment port is an argument (procs + data, not a class tree)
   process_order :: proc(order: Order, pay: Payment_Port) -> Error

   // Hard to test — constructs the real backend inside
   process_order :: proc(order: Order) -> Error {
       gateway := stripe_create()  // hidden
       ...
   }
   ```

2. **Return results; minimise hidden side effects** at the seam under test.

3. **Small surface.** Fewer entry points and params → simpler tests.

4. Prefer testing behaviour through the public surface over poking private
   layout — unless the bug is *in* the representation (then a focused layout
   test is fine).

## Relationships

- A **Module** has one **public surface**.
- **Depth** is measured against that surface.
- A **Seam** is where the surface lives.
- An **Adapter** sits at a **Seam**.
- **Depth** produces **Leverage** and **Locality**.

## Rejected framings

- **Depth as LOC ratio** (implementation lines / interface lines): rewards padding.
- **"Interface" as language `interface` / abstract class / virtual methods.**
- **"Replace switch with polymorphism"** as a design goal — here switch on a
  tagged union *is* the preferred polymorphism.
- **Boundary** when you mean seam (DDD overload).

## Going deeper

- **Deepening a cluster given its dependencies** — [DEEPENING.md](DEEPENING.md).
- **Exploring alternative public surfaces** — [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md).

---

Source: https://github.com/mattpocock/skills (skills/engineering/codebase-design) — MIT.
Heavily adapted: plain data + free functions; no class/interface hierarchy framing.
