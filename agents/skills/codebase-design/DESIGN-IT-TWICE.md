# Design It Twice

When the user wants to explore alternative **public surfaces** for a chosen
deepening candidate, use this parallel sub-agent pattern. Based on "Design It
Twice" (Ousterhout) — your first idea is unlikely to be the best.

Uses the vocabulary in [SKILL.md](SKILL.md) — **module**, **public surface**,
**seam**, **adapter**, **leverage**. Surfaces are free-function oriented, not
class APIs.

## Process

### 1. Frame the problem space

Before spawning sub-agents, write a user-facing explanation of the problem space:

- Constraints any new public surface must satisfy
- Dependencies and which category they fall into (see [DEEPENING.md](DEEPENING.md))
- A rough illustrative sketch (procs + data) to ground constraints — not a proposal

Show this to the user, then immediately proceed to Step 2 so they can think while
sub-agents work.

### 2. Spawn sub-agents

Spawn 3+ sub-agents in parallel when the host supports it; otherwise explore
designs sequentially. Each must produce a **radically different** public surface
for the deepened module.

Give each agent a different design constraint, for example:

- Agent 1: "Minimize the surface — 1–3 entry points max. Maximise leverage per entry."
- Agent 2: "Maximise flexibility — support many use cases without speculative layers."
- Agent 3: "Optimise for the most common caller — make the default case trivial."
- Agent 4 (if applicable): "Design around an explicit ops/port table for cross-seam deps."

Include [SKILL.md](SKILL.md) vocabulary and project `CONTEXT.md` terms in the brief.

Each agent outputs:

1. Public surface (procs, params, structs — plus invariants, ordering, error modes, perf notes)
2. Usage example for callers
3. What the implementation hides behind the seam (including data layout if relevant)
4. Dependency strategy and adapters (see [DEEPENING.md](DEEPENING.md))
5. Trade-offs — where leverage is high, where it's thin

**Forbidden in designs:** class hierarchies, virtual dispatch, "interface with one
implementation" as the default shape.

### 3. Present and compare

Present designs so the user can absorb each one, then compare in prose on
**depth**, **locality**, and **seam placement**. Give an opinionated
recommendation; propose a hybrid if elements combine well.

Source: mattpocock/skills codebase-design/DESIGN-IT-TWICE.md — MIT; adapted to procedural DOD.
