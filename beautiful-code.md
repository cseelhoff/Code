# Beautiful Code — Reference Examples

> Companion to always-on style (`shared/coding-style.md`, installed as
> `User/prompts/copilot-instructions.md` for Copilot and `AGENTS.md` for Grok).
> A catalog of "good code" patterns that respect the machine, paired against
> the generic "slop" an AI tends to emit by default. All examples in Odin. The
> throughline: do the work once analytically, exploit the actual data
> representation, and let the machine do less.
>
> Axes covered: bit-level representation tricks, closed-form over per-tick
> polling, bitsets + bitwise ops, tagged unions over virtual dispatch, SoA over
> AoS, integer handles + ZII sentinels, precompute over recompute, branchless
> hot loops.

---

## 1. Fast inverse square root (the classic)

**Slop** — calls into the math lib, hides the cost, full `sqrt` + divide:
```odin
inv_sqrt :: proc(x: f32) -> f32 {
    return 1.0 / math.sqrt(x)
}
```
**Lean** — exploit the IEEE-754 bit layout: a shift on the integer bits *is* a
first-order log/exp, then one Newton step:
```odin
inv_sqrt :: #force_inline proc(x: f32) -> f32 {
    i := transmute(i32)x
    i = 0x5f3759df - (i >> 1)         // initial guess via bit-level log approximation
    y := transmute(f32)i
    return y * (1.5 - 0.5 * x * y * y) // one Newton-Raphson iteration
}
```

---

## 2. Exponential decay: per-tick polling vs. closed-form on read

**Slop** — an `update` that must run every frame, accumulates float error, ties
correctness to frame rate:
```odin
update_heat :: proc(e: ^Entity, dt: f32) {
    e.heat -= e.heat * COOL_RATE * dt   // must run EVERY tick or it's wrong
}
```
**Lean** — store a timestamp, reconstruct analytically the instant anyone reads
it; O(1), frame-rate independent, zero drift:
```odin
heat_at :: #force_inline proc(e: Entity, now: Seconds) -> f32 {
    elapsed := now - e.heat_set_at
    return e.heat0 * math.exp(-COOL_RATE * f32(elapsed))
}
```

---

## 3. Branchless `abs` / sign-clear on floats

**Slop** — a data-dependent branch the predictor can miss in a hot loop:
```odin
fabs :: proc(x: f32) -> f32 {
    if x < 0 do return -x
    return x
}
```
**Lean** — clear the sign bit; no branch, vectorizes cleanly:
```odin
fabs :: #force_inline proc(x: f32) -> f32 {
    return transmute(f32)(transmute(u32)x & 0x7fff_ffff)
}
```

---

## 4. Set membership: array scan vs. bitset + bitwise test

**Slop** — a `[dynamic]` of enums plus a linear search per query:
```odin
has_status :: proc(active: [dynamic]Status, s: Status) -> bool {
    for a in active do if a == s do return true
    return false
}
```
**Lean** — model the finite set as a `bit_set`; membership and intersection
collapse to single instructions:
```odin
StatusSet :: bit_set[Status]

has_status :: #force_inline proc(active: StatusSet, s: Status) -> bool {
    return s in active
}
// bonus: "do these share any status?" is one AND, no loop
overlaps :: #force_inline proc(a, b: StatusSet) -> bool {
    return a & b != {}
}
```

---

## 5. Polymorphism: virtual-ish dispatch vs. tagged union + switch

**Slop** — a vtable-of-procs struct, the OOP reflex; pointer-chasing, no
inlining, cache-hostile:
```odin
Shape :: struct {
    area: proc(self: rawptr) -> f32,
    data: rawptr,
}
total_area :: proc(shapes: []Shape) -> f32 {
    sum: f32
    for s in shapes do sum += s.area(s.data) // indirect call per element
    return sum
}
```
**Lean** — a tagged union; the `switch` is predictable and the bodies inline:
```odin
Shape :: union { Circle, Rect }
Circle :: struct { r: f32 }
Rect   :: struct { w, h: f32 }

area :: proc(s: Shape) -> f32 {
    switch v in s {
    case Circle: return math.PI * v.r * v.r
    case Rect:   return v.w * v.h
    }
    return 0
}
```

---

## 6. AoS vs. SoA for a hot transform

**Slop** — array of fat structs; summing one field drags whole cache lines of
unused bytes:
```odin
Particle :: struct { pos, vel: [3]f32, color: [4]u8, mass, lifetime: f32 }
total_y :: proc(ps: []Particle) -> f32 {
    sum: f32
    for p in ps do sum += p.pos.y   // strided, cache-wasting
    return sum
}
```
**Lean** — Struct-of-Arrays; the hot field is contiguous and SIMD-friendly:
```odin
Particles :: struct {
    pos_x, pos_y, pos_z: [dynamic]f32,
    vel_x, vel_y, vel_z: [dynamic]f32,
    mass, lifetime:      [dynamic]f32,
}
total_y :: proc(p: Particles) -> f32 {
    sum: f32
    for y in p.pos_y do sum += y    // packed, auto-vectorizes
    return sum
}
```

---

## 7. Object references vs. integer handles

**Slop** — pointers into a `[dynamic]` array (dangle on resize), plus a nullable
parent:
```odin
Node :: struct { parent: ^Node, value: f32 }   // pointer invalidated on growth
```
**Lean** — handles index a flat array; stable across reallocation, serializable,
and a sentinel index removes the null:
```odin
Handle :: distinct u32
NO_PARENT :: Handle(max(u32))

Node :: struct { parent: Handle, value: f32 }
nodes: [dynamic]Node
// nodes[u32(h)] — no dangling, no pointer chasing
```

---

## 8. Population count: loop vs. precomputed / intrinsic

**Slop** — bit-by-bit loop, 32 iterations regardless of input:
```odin
popcount :: proc(x: u32) -> int {
    n: int
    v := x
    for v != 0 { n += int(v & 1); v >>= 1 }
    return n
}
```
**Lean** — defer to the hardware instruction; one cycle on modern CPUs:
```odin
popcount :: #force_inline proc(x: u32) -> int {
    return int(intrinsics.count_ones(x))
}
```

---

## 9. Round up to power of two: branchy loop vs. bit smear

**Slop** — multiply in a loop until it fits:
```odin
next_pow2 :: proc(x: u32) -> u32 {
    p: u32 = 1
    for p < x do p <<= 1
    return p
}
```
**Lean** — smear the top bit down, then add one; data-parallel, no loop:
```odin
next_pow2 :: #force_inline proc(x: u32) -> u32 {
    v := x - 1
    v |= v >> 1;  v |= v >> 2;  v |= v >> 4
    v |= v >> 8;  v |= v >> 16
    return v + 1
}
```

---

## 10. Precompute over recompute: per-call `sin` vs. init-time table

**Slop** — transcendental in the hot path, recomputed for values that never
change:
```odin
wave :: proc(i: int) -> f32 {
    return math.sin(f32(i) * (2*math.PI / 256))   // 256 distinct inputs, ever
}
```
**Lean** — the answer set is static and finite, so bake it once during init and
index:
```odin
sin_table: [256]f32
init_sin_table :: proc() {
    for i in 0..<256 do sin_table[i] = math.sin(f32(i) * (2*math.PI / 256))
}
wave :: #force_inline proc(i: int) -> f32 {
    return sin_table[i & 255]   // mask = free wraparound
}
```

---

## 11. Ring buffer: modulo vs. power-of-two masking

**Slop** — a general modulo on every access (slow integer divide) plus a
separate count field to track fullness:
```odin
Ring :: struct { data: [dynamic]f32, head, count: int }
push :: proc(r: ^Ring, v: f32) {
    idx := (r.head + r.count) % len(r.data)   // division per push
    r.data[idx] = v
    r.count += 1
}
```
**Lean** — size to a power of two so wraparound is a single AND; no divide:
```odin
RING_CAP :: 1024                    // power of two
Ring :: struct { data: [RING_CAP]f32, head, tail: u32 }
push :: #force_inline proc(r: ^Ring, v: f32) {
    r.data[r.tail & (RING_CAP - 1)] = v   // mask, no modulo
    r.tail += 1
}
```

---

## 12. Allocation: per-item heap allocs vs. arena / bump allocator

**Slop** — a `new` per node, scattered across the heap, freed one at a time:
```odin
build :: proc(n: int) -> [dynamic]^Node {
    out: [dynamic]^Node
    for i in 0..<n {
        node := new(Node)            // individual heap alloc, cache-scattered
        append(&out, node)
    }
    return out
}
```
**Lean** — bump-allocate from one contiguous arena; allocation is a pointer add,
and the whole batch frees at once:
```odin
build :: proc(n: int, arena: ^mem.Arena) -> []Node {
    nodes := make([]Node, n, mem.arena_allocator(arena)) // one contiguous block
    for &node in nodes do init_node(&node)
    return nodes                     // free_all(arena) reclaims everything O(1)
}
```

---

## 13. Branchless clamp

**Slop** — two data-dependent branches in a hot numeric loop:
```odin
clamp01 :: proc(x: f32) -> f32 {
    if x < 0 do return 0
    if x > 1 do return 1
    return x
}
```
**Lean** — `min`/`max` lower to branchless select instructions and vectorize:
```odin
clamp01 :: #force_inline proc(x: f32) -> f32 {
    return min(max(x, 0), 1)
}
```

---

## 14. Morton / Z-order encode: interleave loop vs. magic-bit spread

**Slop** — interleave two 16-bit coords bit-by-bit in a loop:
```odin
morton2 :: proc(x, y: u16) -> u32 {
    code: u32
    for i in u32(0)..<16 {
        code |= ((u32(x) >> i) & 1) << (2*i)
        code |= ((u32(y) >> i) & 1) << (2*i + 1)
    }
    return code
}
```
**Lean** — spread the bits with a fixed mask cascade, then merge; no loop, pure
data-parallel shifts:
```odin
spread2 :: #force_inline proc(v: u16) -> u32 {
    x := u32(v)
    x = (x | (x << 8)) & 0x00FF00FF
    x = (x | (x << 4)) & 0x0F0F0F0F
    x = (x | (x << 2)) & 0x33333333
    x = (x | (x << 1)) & 0x55555555
    return x
}
morton2 :: #force_inline proc(x, y: u16) -> u32 {
    return spread2(x) | (spread2(y) << 1)
}
```

---

## 15. Swap without temp / XOR vs. multi-assignment

**Slop** — the "clever" XOR swap people reach for to look smart; actually slower
(serial dependency) and breaks when both refer to the same slot:
```odin
swap :: proc(a, b: ^int) {
    a^ ~= b^;  b^ ~= a^;  a^ ~= b^   // serial chain, fails when a == b
}
```
**Lean** — let the language do a parallel multi-assignment; clearer and the
compiler picks optimal moves:
```odin
swap :: #force_inline proc(a, b: ^int) {
    a^, b^ = b^, a^
}
```
Lesson: "beautiful" is not "maximally clever." The bit trick here is the *slop*.

---

## 16. Default value: optional/pointer check vs. ZII zero value

**Slop** — a nullable pointer for "maybe configured," checked at every read:
```odin
Config :: struct { volume: ^f32 }
get_volume :: proc(c: Config) -> f32 {
    if c.volume != nil do return c.volume^   // null check on every access
    return 1.0
}
```
**Lean** — design the zero value to be the valid default; no pointer, no check:
```odin
Config :: struct { volume: f32 }             // zero value handled at init
DEFAULT_VOLUME :: 1.0
config_init :: proc() -> Config { return { volume = DEFAULT_VOLUME } }
get_volume :: #force_inline proc(c: Config) -> f32 { return c.volume }
```

---

## 17. Sorted-set intersection: nested loop vs. linear merge

**Slop** — O(n*m) nested scan, the first thing that comes to mind:
```odin
intersect :: proc(a, b: []i32) -> [dynamic]i32 {
    out: [dynamic]i32
    for x in a do for y in b do if x == y do append(&out, x)
    return out
}
```
**Lean** — both are sorted, so walk them once with two cursors; O(n+m), branch-
predictable, cache-linear:
```odin
intersect :: proc(a, b: []i32, out: ^[dynamic]i32) {
    i, j := 0, 0
    for i < len(a) && j < len(b) {
        if      a[i] < b[j] do i += 1
        else if a[i] > b[j] do j += 1
        else { append(out, a[i]); i += 1; j += 1 }
    }
}
```

---

## 18. Even/odd & divisibility: modulo vs. bit mask

**Slop** — integer modulo for a power-of-two test:
```odin
is_even :: proc(x: int) -> bool { return x % 2 == 0 }
aligned_16 :: proc(x: uintptr) -> bool { return x % 16 == 0 }
```
**Lean** — for power-of-two divisors, a mask is exact and far cheaper than a
divide:
```odin
is_even   :: #force_inline proc(x: int) -> bool { return x & 1 == 0 }
aligned_16 :: #force_inline proc(x: uintptr) -> bool { return x & 15 == 0 }
```

---

## 19. Enum-indexed lookup: switch ladder vs. flat array

**Slop** — a `switch` that recomputes a constant mapping on every call:
```odin
Element :: enum { Fire, Water, Earth, Air }
resist_multiplier :: proc(e: Element) -> f32 {
    switch e {
    case .Fire:  return 0.5
    case .Water: return 1.5
    case .Earth: return 1.0
    case .Air:   return 0.75
    }
    return 1.0
}
```
**Lean** — Odin's `[Element]f32` array is indexed directly by the enum; the
table *is* the function, no branching:
```odin
RESIST := [Element]f32{
    .Fire = 0.5, .Water = 1.5, .Earth = 1.0, .Air = 0.75,
}
resist_multiplier :: #force_inline proc(e: Element) -> f32 { return RESIST[e] }
```

---

## 20. Counting with a condition: branch-accumulate vs. mask-add

**Slop** — a branch inside the hot loop to count elements over a threshold;
mispredicts on random data:
```odin
count_above :: proc(xs: []f32, t: f32) -> int {
    n: int
    for x in xs do if x > t do n += 1   // unpredictable branch
    return n
}
```
**Lean** — turn the predicate into a 0/1 and add unconditionally; branchless and
SIMD-reducible:
```odin
count_above :: proc(xs: []f32, t: f32) -> int {
    n: int
    for x in xs do n += int(x > t)      // bool->int, no branch
    return n
}
```

---

## Throughline

Across all 20: prefer the representation the hardware already understands
(IEEE-754 bits, power-of-two masks, contiguous arrays, bitsets), do repeated or
static work *once* (precompute, closed-form, arenas), and keep hot loops
branchless and vectorizable. "Beautiful" tracks *less total work for the
machine* — not cleverness for its own sake (see #15: the clever XOR swap is the
slop).
