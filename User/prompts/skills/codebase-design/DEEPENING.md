# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies.
Assumes the vocabulary in [SKILL.md](SKILL.md) — **module**, **public surface**,
**seam**, **adapter**. Modules are plain data + free functions (or packages of
those), not class hierarchies.

## Dependency categories

When assessing a candidate for deepening, classify its dependencies. The
category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the
modules and test through the new public surface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (embedded DB, in-memory filesystem).
Deepenable if the stand-in exists. Test with the stand-in in the suite. Seam may
stay internal.

### 3. Remote but owned

Your own services across a network boundary. Define a **port** as a small set of
procs (or a struct of function pointers / explicit ops table) at the seam — not
an OOP interface hierarchy. The deep module owns the logic; transport is an
**adapter** package. Tests use an in-memory adapter; production uses HTTP/gRPC/queue.

### 4. True external

Third-party services you don't control. Deepened module takes the external
dependency as an injected port (procs + data); tests provide a fake adapter.

## Seam discipline

- **One adapter means a hypothetical seam. Two adapters means a real one.**
  Don't introduce a port unless at least two adapters are justified (typically
  production + test).
- **Internal seams vs external seams.** A deep module can have private internal
  seams for its own tests; don't expose them through the public surface just
  because tests use them.

## Testing strategy: replace, don't layer

- Old unit tests on shallow modules become waste once tests at the deepened
  public surface exist — delete them when superseded.
- Write new tests at the deepened surface. The **public surface is the test surface**.
- Assert on observable outcomes, not private layout — unless the layout *is* the
  contract (e.g. SoA packing invariants).
- Tests should survive internal refactors when they describe behaviour.

Source: mattpocock/skills codebase-design/DEEPENING.md — MIT; adapted to procedural DOD.
