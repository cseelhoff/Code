# Integration Plan: mattpocock/skills + ponytail → GitHub Copilot (VS Code)

**Status:** plan only — do not implement until instructed.

Personal Copilot profile repo (`cseelhoff/Code`): always-on instructions, skills, and reference material for VS Code. This document is the **refined plan** after cross-review with `claude_plan.md`.

**Sources analyzed**

| Source | Version / note | Role |
|--------|----------------|------|
| This repo | `main` (local) | Target: `User/prompts/` + `beautiful-code.md` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | **v1.1.0** (MIT) | Process, grilling, domain docs, engineering flows |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | ~4.8.x (MIT) | YAGNI ladder, minimal solutions, over-engineering review |
| `claude_plan.md` | peer plan | Independent recommendations + challenges to earlier grok draft |

Both upstreams are MIT — vendoring with attribution is clean.

---

## 1. Current project (what we have)

Portable **VS Code user-data** layout for GitHub Copilot. Install: copy `User/` into `%APPDATA%\Code\User` (or Insiders), then reload.

```
.
├── User/prompts/
│   ├── copilot-instructions.md    # always-on (applyTo: "**")
│   └── skills/
│       └── grill-with-docs/       # grilling + CONTEXT.md + ADRs (monolithic, flattened)
│           ├── SKILL.md
│           ├── CONTEXT-FORMAT.md
│           └── ADR-FORMAT.md
├── beautiful-code.md              # Odin slop-vs-lean performance catalog
├── claude_plan.md                 # peer plan
└── grok_plan.md                   # this plan
```

### Layer roles today

| Layer | Path | Behavior |
|-------|------|----------|
| Always-on | `User/prompts/copilot-instructions.md` | Global coding style / philosophy |
| Skills | `User/prompts/skills/<name>/SKILL.md` | On-demand / model-triggered workflows (`name` + `description` frontmatter) |
| Reference | `beautiful-code.md` | Attach for representation-level / hot-path work |

### Existing philosophy (non-negotiables)

- Data-oriented + procedural; no OOP / class hierarchies / Clean Code dogma
- Polymorphism = tagged union + switch
- Closed-form / event-driven over per-tick polling
- SoA by default; integer handles not pointers
- Performance-first; branchless hot loops, bitsets, precompute, SIMD-friendly layout
- Don’t abstract early; hand-roll small code over heavy deps (builtins like crypto / serialization OK)
- Tests as a tool — prefer **after** the code; not dogmatic TDD
- ZII, design away null, validate at trust boundaries only

### Existing skill

`grill-with-docs` is the **older monolithic** form of Matt’s skill (interview + domain glossary + ADR rules inlined). Upstream v1.1.0 splits into `grilling` + `domain-modeling` + a thin wrapper. **Decision: keep monolithic** (see §8, §12).

---

## 2. Upstream snapshots

### mattpocock/skills — process & alignment

Solves misalignment, jargon drift, blind coding, architecture entropy.

```
grill-with-docs
  → (optional prototype + handoff)
  → implement  [upstream drives tdd + code-review]
  or to-spec → to-tickets → implement per ticket

On-ramps: diagnosing-bugs | triage | wayfinder
Underneath: domain-modeling | codebase-design | grilling
```

### ponytail — solution minimalism

Solves over-building. Ladder (after reading the real flow): YAGNI → reuse → stdlib → native → deps → one line → minimum.

Companion skills: `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`.

This repo’s delivery model is **copy `User/`** (instructions + skills), not Copilot CLI hooks/plugins unless CLI becomes primary later.

---

## 3. Philosophy matrix

| Theme | Verdict | Resolution |
|-------|---------|------------|
| No unrequested abstractions / prefer few files | **Match** | Keep |
| Hand-roll vs “use installed deps” | **Tension** | **Adapted ladder** (§4) — never *prefer* new deps; hand-roll small pieces |
| Boring over clever vs `beautiful-code.md` | **Resolved** | House rule §5 |
| Ponytail: one small check for non-trivial logic | **Match** | Fits “tests are a tool” |
| Matt `/tdd` + `/implement` defaults | **Hard conflict** | **Do not port** (§8, §12) |
| Matt tracker pipeline | **Skip** | Too much machinery for a global profile |
| Matt `codebase-design` “interfaces” | **Optional later, adapted** | Deep modules as data + free functions; never class hierarchies |
| Full ponytail body always-on | **Layer carefully** | ~12-line ladder + conflict order always-on; intensity via skill |

---

## 4. Key adaptation — the laziness ladder (hand-roll stance)

Adopted and sharpened from `claude_plan.md`. Ponytail’s rung 5 (“installed dependency → use it”) conflicts with this profile’s “hand-rolling is usually fine; a dependency is code you don’t control,” while still allowing focused builtins.

**Adapted ladder (always-on + `ponytail` skill):**

1. Does this need to exist at all? → no: skip (**YAGNI**)
2. Already in this codebase? → reuse
3. Stdlib / **language builtin** does it? → use it (crypto, serialization packages in that class are fine)
4. Native platform feature covers it? → use it
5. **Adapted:** an *already-vendored* dependency solves it → use it. **Default: do not add a new dependency.** Prefer hand-rolling a small custom piece. New deps only when the user explicitly asks, or the problem is in the small “battle-tested focused package you can’t realistically beat” class already named in the instructions.
6. Can it be one line? → one line *(subject to §5 — not if that one line is the wrong algorithm)*
7. Only then: the minimum that works

**Also keep:** the `ponytail:` shortcut-comment marker (ceiling + upgrade path). Fits “comment the *why*, not the *what*.”

**Not adopted verbatim from Claude:** absolute **“Never add a new dependency”** as a hard law. That overshoots the house instructions (builtins + rare justified packages). Use the softer default above so agents don’t refuse a clearly correct focused dep the user wants.

---

## 5. House rule — boring vs clever (authoritative)

Confirmed by project author; also adopted into `claude_plan.md`.

Ponytail’s “boring over clever” / “shortest working diff” **must not** become an excuse to skip real performance work. Read literally, they collide with `beautiful-code.md` (fast inv-sqrt, Morton codes, branchless masks, closed-form decay, etc.).

**Rule:**

- **Clever is fine** when it is a real, idiomatic solution with a **real performance boost**.
- It must **not** overcomplicate readability **for no real advantage**.
- If purpose stays **intuitive** — even with comments explaining the *why* — it is fine.
- **Bottom line:** boring is not an excuse to skip major performance improvements.

**Conflict order (embed in always-on *and* `ponytail` skill so they never drift):**

1. Correctness / safety / trust boundaries / data-loss handling  
2. **Real performance of the work that matters** (hot paths; may be “clever”)  
3. Fewest lines / fewest files / no unrequested abstraction (ponytail)  
4. Clever *without* measurable or structural advantage → reject (e.g. XOR-swap, `beautiful-code.md` #15)

“Boring over clever” means **no clever abstractions without payoff** — not “skip representation-level wins.”

---

## 6. Target architecture

```
User/prompts/
├── copilot-instructions.md          # Layer 1: style + ~12-line ladder + §5 order
└── skills/                          # Layer 2: flattened <name>/SKILL.md (no category folders)
    ├── grill-with-docs/             # keep as-is (monolithic)
    ├── ponytail/
    ├── ponytail-review/
    ├── diagnosing-bugs/
    ├── handoff/
    ├── code-review/
    ├── research/                    # Phase B (from Claude; adopted)
    ├── writing-great-skills/        # Phase B (from Claude; adopted)
    ├── ponytail-audit/              # Phase C
    ├── ponytail-debt/               # Phase C
    └── ask-skills/                  # Phase C optional only
beautiful-code.md                    # Layer 3; fix stale path if needed
```

### Layer 1 — always-on

Keep non-negotiables at the top. Add, in the existing anti-over-engineering voice (~12 lines of ladder + short conflict-order bullet):

- Adapted ladder (§4)
- Lazy about size, not about reading; root-cause at shared call sites
- Conflict order (§5)
- Pointers: intensity → `ponytail`; complexity hunt → `ponytail-review`

Do **not** paste the full ponytail skill body into always-on.

### Layer 2 — phased skills

#### Phase A — high value, low conflict

| Item | Source | Work |
|------|--------|------|
| Always-on ladder + §5 | both | Compact; hand-roll-adapted rung 5 |
| `ponytail` | ponytail | Levels lite/full/ultra; house-rule block; DOD non-negotiables; adapted ladder |
| `ponytail-review` | ponytail | Over-engineering delete-list **plus DOD inverse**: flag “lean” but cache-hostile / representation-naive / wrong layout |
| `diagnosing-bugs` | matt | Port; include supporting files if any |
| `handoff` | matt | Port |

#### Phase B — workflow, no tracker

| Item | Source | Work |
|------|--------|------|
| `code-review` | matt | **Standards primary source = this profile** (`copilot-instructions.md` + `beautiful-code.md`). Spec = issue/PRD/conversation. **Do not** depend on `docs/agents/issue-tracker.md`. Optional complexity pass → `ponytail-review`. See §7.3 on Fowler. |
| `research` | matt | Port with light adaptation (paths/background-agent assumptions for VS Code Copilot) — **not** blind wholesale if scripts assume Claude-only features |
| `writing-great-skills` | matt | Port + supporting `GLOSSARY.md` if present; this repo *is* a skills library |

#### Phase C — optional

| Item | Note |
|------|------|
| `ponytail-audit`, `ponytail-debt` | Useful on large *target* codebases; fine in the global pack if descriptions stay on-demand |
| `ask-skills` | Local router only if discoverability hurts; maintenance cost is real (Claude) |
| `codebase-design` (adapted) | DOD language only; not in Claude’s port list — keep optional, not permanently discarded |
| Refresh grill formats only | No split into `grilling` + `domain-modeling` |

#### Do not port

| Item | Why |
|------|-----|
| `tdd`, `implement` | TDD-default / ticket-driven flow conflicts with “tests after code.” **Skip, don’t defer as “opt-in later”** (Claude right; earlier grok soft-deferred — revised) |
| `to-spec`, `to-tickets`, `triage`, `wayfinder`, `setup-matt-pocock-skills` | Issue-tracker machinery |
| `ask-matt` | Routes a suite we are not shipping; if anything, a tiny local `ask-skills` later |
| `grill-me`, `grilling`, `domain-modeling` as separate skills | Monolithic `grill-with-docs` already covers; split is premature abstraction for this profile |
| `ponytail-gain`, `ponytail-help` | Scoreboard / command card; low value |
| `teach`, personal/misc Matt skills | Out of scope |
| CLI hooks / marketplace plugin packaging | Wrong install model for this repo |

---

## 7. Adaptation notes

### 7.1 `ponytail` skill house-rule block

Must restate:

- Adapted ladder (§4)
- Conflict order (§5)
- DOD non-negotiables (SoA, handles, tagged unions, ZII, no virtual dispatch)
- Data layout / machine work beats golfed line count when they disagree
- Comments for non-obvious performance intent are expected

### 7.2 `ponytail-review` — DOD inverse

Upstream only hunts over-engineering. For this house, also flag:

- Few lines but **wrong representation** (AoS in a hot transform, pointer soup, polling where closed-form fits)
- “Lean” that is **cache-hostile** or forces predictable branchy work on hot paths
- Premature “one-liner” that picks the flimsier algorithm

Do **not** flag deliberate hot-path bit tricks that pay for themselves and stay legible with a short *why* comment.

### 7.3 `code-review` — Standards baseline

**Refined vs Claude:** Claude recommends keeping Fowler smells *filtered* through a DOD lens. That still leaves an agent primed with Clean-Code reflexes (“long method,” “feature envy”) that fight this profile.

**Preferred Standards baseline:**

1. Primary: `copilot-instructions.md` + `beautiful-code.md` (explicit DOD / performance checklist)  
2. Secondary: only those Fowler items that survive a hard filter (e.g. real duplication of non-trivial logic, dead code) — **never** flag long procedural functions, free-function modules, or switch-on-union as smells  
3. Spec axis unchanged  
4. Complexity: `ponytail-review` pass  

### 7.4 `grill-with-docs`

**Locked: keep monolithic.** Splitting into `grilling` + `domain-modeling` is premature abstraction for a personal profile until a second skill must compose the pieces (Claude’s challenge accepted).

### 7.5 Frontmatter / VS Code skill loader

Observed required fields: `name` + `description` (see existing `grill-with-docs`).

**`disable-model-invocation`:** appears in Matt’s Claude-oriented skills. **Do not ship it** until verified against VS Code / GitHub Copilot skill docs for this loader. Unverified keys are noise or breakage risk (Claude’s challenge accepted).

Recommended attribution frontmatter (Claude — adopted):

```yaml
name: ...
description: ...
license: MIT
# source: https://github.com/.../path/to/skill  (if the loader ignores unknown keys, put source in the body)
```

If unknown keys are stripped/ignored, put `Source:` + license in the skill body and a **Credits** section in `README.md`.

### 7.6 Flattening and self-containment

- Skills live at `User/prompts/skills/<name>/` (no `engineering/` / `productivity/` folders)  
- Port by shallow-clone → copy folder → **strip dangling references** to un-ported skills (`/tdd`, `/implement`, issue tracker, `ask-matt`, etc.)  
- Every skill must be self-contained  

### 7.7 Install

Unchanged: sync `User/` → VS Code profile, reload, confirm skills appear beside `grill-with-docs`.

---

## 8. Day-to-day flow (post-integration)

```
1. New idea / feature
   → grill-with-docs

2. Implementation
   → always-on: DOD + adapted ladder + §5
   → /ponytail full|ultra when overbuilding
   → tests after, focused on critical / tricky paths

3. Before commit
   → code-review
   → ponytail-review

4. Hard bug / regression
   → diagnosing-bugs

5. Need primary sources
   → research

6. Long thread dying
   → handoff

7. Editing this skills repo itself
   → writing-great-skills
```

No default TDD loop. No tracker pipeline.

---

## 9. File-by-file implementation checklist

| # | File | Action | Phase |
|---|------|--------|-------|
| 1 | `User/prompts/copilot-instructions.md` | Adapted ladder + §5 conflict order | A |
| 2 | `User/prompts/skills/ponytail/SKILL.md` | Adapted + house rules + levels | A |
| 3 | `User/prompts/skills/ponytail-review/SKILL.md` | Over-eng + DOD inverse | A |
| 4 | `User/prompts/skills/diagnosing-bugs/SKILL.md` (+ support) | Port | A |
| 5 | `User/prompts/skills/handoff/SKILL.md` | Port | A |
| 6 | `User/prompts/skills/code-review/SKILL.md` | Port + Standards = this profile | B |
| 7 | `User/prompts/skills/research/SKILL.md` | Port + light VS Code adaptation | B |
| 8 | `User/prompts/skills/writing-great-skills/…` | Port + glossary if needed | B |
| 9 | `User/prompts/skills/ponytail-audit/SKILL.md` | Port | C |
| 10 | `User/prompts/skills/ponytail-debt/SKILL.md` | Port | C |
| 11 | `User/prompts/skills/ask-skills/SKILL.md` | Optional local router | C |
| 12 | `README.md` | Skills catalog + Credits (MIT + URLs) | with A/B |
| 13 | `beautiful-code.md` | Fix stale companion path (`.github/…` → `User/prompts/…`) | A |

---

## 10. Porting method

1. Shallow-clone both MIT repos to a temp dir (exact sources + supporting files).  
2. Copy selected skill folders under `User/prompts/skills/<name>/` (flattened).  
3. Apply ladder / house-rule / Standards adaptations; strip dangling cross-skill refs.  
4. Preserve MIT attribution (frontmatter and/or README Credits).  
5. Verify (§11).  

---

## 11. Verification

1. Each new `SKILL.md` has valid `name` + `description` (match `grill-with-docs` shape).  
2. Grep skills for dangling refs and expect **zero** needed hits: `/tdd`, `/to-spec`, `/to-tickets`, `/implement`, `/triage`, `/wayfinder`, `ask-matt`, `issue-tracker`, `/ponytail-gain` (unless deliberately documenting “not installed”).  
3. Always-on ladder + `ponytail` skill do not contradict hand-roll / §5.  
4. Sync `User/` → profile, reload, skills visible; README renders; licenses present.  
5. Spot-check: agent must not reject a hot-path bit trick that is idiomatic and commented; must not introduce a new dep when hand-roll fits.  

---

## 12. Decisions locked

| Decision | Choice |
|----------|--------|
| Profile shape | VS Code `User/prompts/` portable config |
| Always-on | Condensed adapted ladder + §5; full intensity via skill |
| Boring vs clever | §5 — real perf wins; clever-without-payoff is slop |
| Ladder rung 5 | Already-vendored OK; default no *new* deps; hand-roll preferred; not absolute “never” |
| `grill-with-docs` | **Monolithic** — do not split |
| `tdd` / `implement` | **Skip** (not “opt-in later”) |
| Tracker suite | Skip |
| `research` + `writing-great-skills` | **Include** Phase B |
| `ask-skills` | Phase C optional; not core |
| `disable-model-invocation` | Do not use until verified on this loader |
| Attribution | MIT + source + README Credits |
| Fowler-as-Standards | Subordinate to DOD checklist; filter hard |

---

## 13. Cross-review: insights adopted from `claude_plan.md`

These improved the earlier grok draft and are **incorporated above**:

1. **Explicit ladder reframe for hand-roll** — rung 5 as already-vendored / prefer hand-roll (clearer than vague “existing deps”).  
2. **`ponytail:` marker** called out as intentional and aligned with “comment the why.”  
3. **MIT attribution mechanics** — per-skill license/source + README Credits.  
4. **Flattened layout** and **porting method** (shallow clone → copy → strip dangling refs).  
5. **Verification checklist** (frontmatter + grep + reload).  
6. **`research` + `writing-great-skills`** — under-weighted in the first grok plan; this repo *is* a skills library, so authoring reference earns its keep; research is useful primary-source work.  
7. **Harder lock: do not split `grill-with-docs`** — premature abstraction for a personal profile.  
8. **Harder lock: skip `tdd`/`implement`**, don’t soft-defer them as “opt-in later.”  
9. **`disable-model-invocation` verification** — don’t ship unconfirmed frontmatter.  
10. **`ask-skills` maintenance cost** — demote to Phase C optional.  
11. **`code-review` must not treat long procedural functions as smells** — DOD lens.  
12. **~12-line always-on ladder** budget and reuse of existing document voice.  
13. **Phase A/B/C sequencing** mutually reinforced (Claude adopted grok’s phasing; refined here).  
14. **`beautiful-code.md` path fix** and **DOD inverse in `ponytail-review`** (shared).  

---

## 14. Cross-review: objectionable or weaker recommendations in `claude_plan.md`

Challenges retained; not adopted as-is:

### 14.1 Absolute “Never add a new dependency”

Claude’s adapted rung 5 says **never** add a new dependency. That is stricter than the house instructions (builtins OK; rare focused packages OK; user may request a dep). **Risk:** agent refuses a justified library or argues with the user.  
**Our stance:** default against new deps + prefer hand-roll; allow the small exceptions already in `copilot-instructions.md` and explicit user request.

### 14.2 Fowler baseline kept as co-equal Standards source

Claude’s recommended option is “keep Fowler smells but filter through DOD.” Agents over-apply Fowler/Clean-Code even with filters.  
**Our stance:** primary Standards = this profile’s instructions + `beautiful-code.md`; Fowler only as a heavily filtered secondary list. Prefer Claude’s option B (DOD checklist) as the real center of gravity.

### 14.3 `research` / others as “port wholesale”

“Wholesale” risks broken assumptions (background agents, Claude paths, un-ported skill cross-links).  
**Our stance:** port content, then **adapt** for self-contained VS Code Copilot use; strip dangling refs (Claude’s own verification section already implies this — file plan should not say “wholesale” without that step).

### 14.4 Treating `domain-modeling` / `codebase-design` as permanently skippable because “grill covers it”

`grill-with-docs` covers domain work *during a grill*. Separate `domain-modeling` or adapted `codebase-design` can still help mid-feature terminology or module-shape work without a full interview.  
**Our stance:** not Phase A/B; **do not permanently discard** `codebase-design` (adapted). Keep as optional Phase C+ if pain appears. No need to split grill now.

### 14.5 File list presents `ponytail-audit` / `ponytail-debt` as core rows while phasing says C

Claude’s file-by-file table lists audit/debt as main port items (#4–5) even though phasing correctly parks them in C.  
**Our stance:** Phase C only — fine to ship eventually, not in the first sync. Avoid loading more model-triggerable skill descriptions than needed on day one.

### 14.6 Under-weighting performance in the ladder’s “one line” rung

Claude adapts deps well but does not always restate that “one line” loses to a correct, faster algorithm under §5.  
**Our stance:** one-line rung is subordinate to conflict order §5 (already in Claude’s house-rule section — must be repeated next to the ladder so agents don’t “win” with a short wrong approach).

### 14.7 Skipping any discoverability aid without a README catalog

Claude defers `ask-skills` (agree) but then discoverability depends entirely on README + memory.  
**Our stance:** **README skills catalog is mandatory** at Phase A/B; `ask-skills` remains optional. Not a disagreement so much as a hardening of the README requirement.

### 14.8 Minor: “scope: port all requested skills” in Claude decisions

Wording is vague relative to the skip list.  
**Our stance:** explicit include/exclude tables in §6 and §12.

---

## 15. What the two plans always agreed on

- Vendored MIT skills into `User/prompts/skills/`, not full upstream monorepos  
- Always-on ladder **and** invokable `ponytail`  
- Adapt, don’t blind-copy, where house style conflicts  
- §5 boring-vs-clever / performance conflict order (author-confirmed)  
- Skip tracker pipeline and `ponytail-gain` / `ponytail-help`  
- `diagnosing-bugs`, `handoff`, adapted `code-review` are high value  
- Fix `beautiful-code.md` companion path  
- Plan only until implementation is requested  

---

## 16. Open choices (implementation pass)

1. Phase A only first, or A+B in one PR?  
2. Include Phase C audit/debt in the same PR or wait until after live use?  
3. `ask-skills` — skip until skill count becomes painful? (recommended: skip)  
4. Copilot CLI plugin/hooks later? (out of scope for v1 of this profile)  

---

## 17. Explicit non-goals

- Replacing house style with raw ponytail `AGENTS.md` alone  
- Dumping the full Matt engineering suite into a global profile  
- Full ponytail skill body in always-on instructions  
- Default red-green TDD  
- Treating “boring” as permission to ship slow or representation-naive code  
- Shipping unverified skill frontmatter keys  

---

*Refined after cross-review of `claude_plan.md`. House rule §5 author-confirmed. Earlier grok draft revised: harder skip on tdd/implement, no grill split, adopt research + writing-great-skills, verify frontmatter, soften absolute no-deps, prefer DOD Standards over Fowler-primary.*
