---
applyTo: "**"
---
# Coding Style Instructions

> Captures the author's coding preferences so AI assistants (GitHub Copilot,
> Claude, etc.) generate code that matches this style by default. Rooted in
> data-oriented design, procedural programming, and a performance-first mindset.
>
> Some repos also ship a `.github/beautiful-code.md` with concrete slop-vs-lean
> code examples — attach it when doing performance-critical or representation-
> level work.

## Non-negotiables (read first)

1. **Data-oriented + procedural.** No OOP, no class hierarchies, no Clean Code
   dogma.
2. **Polymorphism = tagged union + switch.** Never virtual dispatch or
   interfaces.
3. **Closed-form / event-driven over per-tick polling.** Store a timestamp,
   reconstruct state analytically on read.
4. **SoA by default; reference entities by integer handle**, not pointer.
5. **Performance-first.** Branchless hot loops, bitsets, precompute static
   results.
6. **Don't abstract early.** Inline cohesive code over premature helpers.

## When rules conflict

Performance first, then readability. A simple, fast, elegant solution beats any
rule applied dogmatically. Every guideline below serves those two goals — not
the other way around.

## Core philosophy

- **Data-oriented design over object-oriented design.** Think about data
  layout, transforms over arrays, and the actual machine. Reject OOP ceremony
  (deep inheritance, getters/setters, design patterns for their own sake).
- **Procedural over OOP.** Free functions that transform plain data, not
  methods bundled into classes hiding state.
- **Static typing.** Explicit, concrete types. No dynamic duck-typing tricks.
- **Performance is a feature.** Prefer designs that minimize wasted work.
- **Reject "Clean Code" dogma.** Tiny functions, excessive indirection, and
  "one reason to change" abstraction are net negatives.
- **Closed-form / event-driven over per-tick polling.** Store a timestamp and
  reconstruct state analytically on read; do not mutate state every tick. This
  is an example of a optimal performance paradigm of simply "doing less"
- **Use early-return guard clauses** to keep the happy path un-indented and
  avoid deep conditional nesting. Reorder for readability only when a guard
  would obscure intent.
- **Descriptive names first.** Code should read clearly without comments.
- A comment is only warranted when the code **deviates from a competent
  reader's natural intuition** about the idiomatic implementation — most often
  when a performance optimization exploits a non-obvious trick. Comment the
  *why*, not the *what*.
- **Return error/sentinel values and check at the call site** (Go/Odin style).
  Avoid exception-driven control flow.
- **Do not abstract early.** Premature generalization is a dangerous pitfall.
  This code will likely never be reused, and early abstraction wastes time.
- **The "rule of three" is not a mandate.** Repeating logic 2–3 times does not
  automatically justify extracting a helper. Inline, cohesive functions are
  fine and often better.
- **Prefer Struct-of-Arrays (SoA) by default** for cache efficiency.
- **Preallocate bounded buffers** sized to a known max; Only grow dynamically
  when no sensible bound exists.
- **Prefer stack allocation over heap** wherever the lifetime is bounded.
- **Use strong/distinct domain types** (Odin `distinct` types, units like
  seconds or meters) to prevent mixing incompatible values.
- Plain primitives are fine where a domain type adds no real safety.
- **Prefer fuller, descriptive names** over terse abbreviations.
- **Hand-rolling is usually fine.** A dependency is code you don't control or
  fully understand, and you typically use a fraction of it while paying its full
  cost in build time, binary size, and transitive deps. A small piece written
  yourself fits your data exactly and keeps the system in your head.
- **Some builtin dependacies are fine like crypto and serialization.** These
  are small focused, battle-tested packages you can't realistically beat on speed or security.
- **Always use unions / enum + switch.** Virtual functions, interfaces,
  and class hierarchies are almost always the wrong choice — avoid them.
- **Reject classes and objects, not just hierarchies.** They force data and
  procedures into one rigid shape that rarely fits. Keep plain data and the
  free functions that transform it separate.
- **Reference entities by integer handles/indices** into arrays, not by
  pointers or direct object references.
- **Pass all state explicitly** through function parameters. Avoid ambient
  globals, singletons, and hidden context.
- **Tests are a tool, not a religion.** Especially valuable to let agentic AI
  iterate productively. Prefer tests written *after* the code, focused on
  tricky or critical logic — not dogmatic TDD.
- **Avoid macros.** Prefer concrete, duplicated code over generic machinery that
  is hard to debug and hard for compilers to optimize.
- **Zero-Is-Initialization (ZII).** Design structs so the all-zero value is a
  valid, ready-to-use default. Avoid constructor logic where a zeroed struct
  would do.
- **Design away null state.** Prefer always-valid data over optionals or
  sentinels. Structure the data so "missing" cannot occur, rather than checking
  for it everywhere.
- **Performance first, readability second.** Style follows from these two
  priorities in that order. 
- **Always think about the problem in terms of performance.** Reach for:
  - **Vector/SIMD-friendly** data and loops (work over packed arrays).
  - **Bitsets over arrays** when representing set membership; use **bitwise
    operations** to test presence/intersection instead of loop iteration.
  - Designs that let the machine do less work overall.
- **Branchless / data-parallel hot loops.** Prefer mask-and-blend over per-
  element branches where it keeps the loop SIMD-friendly.
- **Batch/array transforms over per-item calls.** Process whole arrays in tight
  one-pass loops rather than calling a function per entity.
- **Smallest numeric type that fits** (e.g. `u8`/`u16`/`f32`) to pack cache
  lines, when it doesn't cost correctness.
- **Performance-first by default**, even on cold paths — but the heaviest
  optimization effort belongs on the measured hot path.
- **Precompute aggressively.** Whenever results are static, compute them at
  compile time, in a preprocessing step, or once during initialization, instead
  of recomputing at runtime. Actively hunt for these opportunities.
- **Choose the data structure from the queries.** Array, hash map, or both —
  decide based on the operations performed and the questions most frequently
  asked of the data.
- **Write code so it can be parallelized later with minimal effort.** Favor
  shared-nothing, data-parallel batch transforms (DOD-style job batches) over
  designs entangled with shared mutable state.
- **Validate only at system boundaries** (untrusted/external input).
