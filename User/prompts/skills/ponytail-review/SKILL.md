---
name: ponytail-review
description: >
  Code review focused on over-engineering and on lean-but-wrong representation.
  Finds what to delete (reinvented stdlib, unneeded deps, speculative
  abstractions) and flags cache-hostile or representation-naive "short" code.
  One line per finding. Use when the user says "review for over-engineering",
  "what can we delete", "is this over-engineered", "simplify review",
  "ponytail-review", or wants a complexity pass after a normal review.
license: MIT
---

# Ponytail Review

Review diffs for unnecessary complexity **and** for "lean" code that is still
the wrong shape for this house (data-oriented / performance-first).

One line per finding: location, tag, what to cut or fix, what replaces it.
The diff's best outcome is getting shorter *or* getting the right layout.

## Format

`L<line>: <tag> <what>. <replacement>.`, or `<file>:L<line>: ...` for
multi-file diffs.

### Tags — over-engineering

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library / language already ships. Name it.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same correct logic, fewer lines. Show the shorter form.
- `dep:` new dependency that a small hand-roll or already-vendored code could replace.

### Tags — DOD inverse (lean but wrong)

- `layout:` few lines but wrong data layout for the access pattern (e.g. AoS in a hot
  transform, pointer soup, scattered heap nodes where an arena/SoA fits). Name the better layout.
- `recompute:` work redone every tick/call when closed-form, precompute, or event-driven fits.
- `branchy:` hot loop with avoidable data-dependent branches that should be mask/branchless
  or batch transform — only when it clearly matters for a hot path.

**Do not flag** idiomatic hot-path bit tricks, closed-form math, or SoA that pay for
themselves and stay legible with a short *why* comment. Those are house style, not bloat.

## Examples

❌ "This EmailValidator class might be more complex than necessary…"

✅ `L12-38: stdlib: 27-line validator class. "@" in email for a first pass; real validation is the confirmation mail.`

✅ `L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`

✅ `repo.py:L88: yagni: AbstractRepository with one implementation. Inline until a second one exists.`

✅ `particles.odin:L40-55: layout: []Particle AoS; hot sum of pos.y. SoA pos_y slice.`

✅ `L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

## Scoring

End with: `net: -<N> lines possible` for pure cuts, and note any `layout:` /
`recompute:` / `branchy:` items separately (they may *add* clarity or change
shape rather than only delete lines).

If there is nothing to cut or reshape: `Lean already. Ship.` and stop.

## Boundaries

- Out of scope for this skill: pure correctness bugs and security holes that are
  not complexity issues — route those to `code-review` / normal review.
- A single smoke test or assert-based self-check is not bloat; never flag it for
  deletion solely for existing.
- Does not apply fixes; only lists findings.
- "stop ponytail-review" / "normal mode": revert to verbose review style.

---

Source: https://github.com/DietrichGebert/ponytail (skills/ponytail-review) — MIT.
Adapted: DOD inverse tags; hand-roll-friendly `dep:`; no flag on paid-for hot-path tricks.
