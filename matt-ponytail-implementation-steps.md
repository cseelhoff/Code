# Matt + Ponytail → Copilot profile: implementation playbook

Repeatable process for vendoring selected skills from
[mattpocock/skills](https://github.com/mattpocock/skills) and
[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) into this
repo (`User/prompts/`). Use this when either upstream releases updates you want
to re-port, or when implementing the next approved phase.

**Design authority:** `grok_plan.md` + `claude_plan.md` (base philosophy) +
**this file** for phase status and re-port procedure.  
**Status:** Phase **A + B done**. Phases **C–E approved, not yet implemented**
(see [Approved next phases](#approved-next-phases-c–e)).

---

## Pinned decisions (do not re-litigate on re-port)

| Topic | Decision |
|-------|----------|
| Ladder rung 5 | Soft default: already-vendored OK; prefer hand-roll; stdlib/builtins + battle-tested focused packages OK; **new** dep only on explicit request or unbeatable-package case |
| Boring vs clever | Conflict order: correctness → real performance → minimalism → clever-without-payoff rejected |
| Always-on tests stance | Prefer tests **after** code for normal work (`copilot-instructions.md`). **`tdd` is opt-in** when the user invokes it or when `implement` drives red-green at agreed seams |
| `grill-with-docs` | **Split shape (Phase C):** thin wrapper = `grilling` + `domain-modeling`. Replace monolithic body |
| `grill-me` | **Port** — grilling without docs (no codebase / no CONTEXT) |
| `grilling` + `domain-modeling` | **Port** as model-reachable primitives; formats live under `domain-modeling/` |
| `tdd` / `implement` | **Port (Phase D)** — not skipped |
| Tracker suite | **Port (Phase E):** `setup-matt-pocock-skills`, `to-spec`, `to-tickets`, `triage`, `wayfinder` |
| `code-review` Standards | DOD-primary (`copilot-instructions.md` + `beautiful-code.md`); Fowler secondary, heavily filtered |
| `codebase-design` | Heavily adapted (plain data + free functions) — already shipped |
| `ponytail-audit` / `ponytail-debt` | Still deferred (after C–E or when audit pain appears) |
| `ask-skills` | Still deferred (README catalog first) |
| Still skip | `ponytail-gain`, `ponytail-help`, `teach`, `prototype`, `improve-codebase-architecture`, Copilot CLI hooks/plugins, personal/misc Matt skills |
| Frontmatter | Ship `name` + `description`; `license: MIT`; put `Source:` in body. Do **not** ship `disable-model-invocation` until verified on VS Code loader |
| Layout | Flatten under `User/prompts/skills/<name>/` (no category folders) |

---

## Skill inventory

### Phase A (core) — **done**

| Skill | Upstream path | Local path |
|-------|---------------|------------|
| (always-on ladder) | ponytail ladder | `User/prompts/copilot-instructions.md` |
| `ponytail` | `skills/ponytail/SKILL.md` | `User/prompts/skills/ponytail/SKILL.md` |
| `ponytail-review` | `skills/ponytail-review/SKILL.md` | `User/prompts/skills/ponytail-review/SKILL.md` |
| `diagnosing-bugs` | `skills/engineering/diagnosing-bugs/` | `User/prompts/skills/diagnosing-bugs/` |
| `handoff` | `skills/productivity/handoff/SKILL.md` | `User/prompts/skills/handoff/SKILL.md` |
| path fix | — | `beautiful-code.md` header |

### Phase B (workflow) — **done**

| Skill | Upstream path | Local path |
|-------|---------------|------------|
| `code-review` | `skills/engineering/code-review/SKILL.md` | `User/prompts/skills/code-review/SKILL.md` |
| `research` | `skills/engineering/research/SKILL.md` | `User/prompts/skills/research/SKILL.md` |
| `writing-great-skills` | `skills/productivity/writing-great-skills/` | `User/prompts/skills/writing-great-skills/` |
| `codebase-design` | `skills/engineering/codebase-design/` | `User/prompts/skills/codebase-design/` |

### Phase C (grill family) — **approved, not implemented**

| Skill | Upstream path | Local path (target) | Notes |
|-------|---------------|---------------------|--------|
| `grilling` | `skills/productivity/grilling/SKILL.md` | `User/prompts/skills/grilling/SKILL.md` | Interview primitive |
| `domain-modeling` | `skills/engineering/domain-modeling/` | `User/prompts/skills/domain-modeling/` | + `CONTEXT-FORMAT.md`, `ADR-FORMAT.md` |
| `grill-me` | `skills/productivity/grill-me/SKILL.md` | `User/prompts/skills/grill-me/SKILL.md` | Thin: run `grilling` only |
| `grill-with-docs` | `skills/engineering/grill-with-docs/SKILL.md` | `User/prompts/skills/grill-with-docs/SKILL.md` | **Replace** monolith with thin: run `grilling` + `domain-modeling`; **remove** local copies of format files from this folder once they live under `domain-modeling/` |

**Migration note:** Today `grill-with-docs/` still holds the old monolithic body +
`CONTEXT-FORMAT.md` + `ADR-FORMAT.md`. Phase C moves formats to `domain-modeling/`,
thins both grill wrappers, and deletes duplicate format files from `grill-with-docs/`.

### Phase D (build loop) — **approved, not implemented**

| Skill | Upstream path | Local path (target) | Adaptation |
|-------|---------------|---------------------|------------|
| `tdd` | `skills/engineering/tdd/` | `User/prompts/skills/tdd/` | Port `SKILL.md`, `tests.md`, `mocking.md`. Opt-in red-green; do not rewrite always-on to force TDD. Prefer seams + behaviour tests; avoid Clean-Code / mock-heavy pressure that fights DOD |
| `implement` | `skills/engineering/implement/SKILL.md` | `User/prompts/skills/implement/SKILL.md` | Drive `tdd` at **pre-agreed** seams when useful; close with `code-review` (and optional `ponytail-review`). Point at local skill names, not missing tracker unless Phase E is done |

**House rule while both always-on and `tdd` exist:**

- Default coding (no skill): tests after, focused on critical paths (instructions).
- User invokes `tdd` or `implement` with red-green intent: follow the skill.
- Never let `implement` silently expand into dogmatic full-suite TDD without agreed seams.

### Phase E (tracker suite) — **approved, not implemented**

| Skill | Upstream path | Local path (target) | Notes |
|-------|---------------|---------------------|--------|
| `setup-matt-pocock-skills` | `skills/engineering/setup-matt-pocock-skills/` | `User/prompts/skills/setup-matt-pocock-skills/` | Full folder: issue-tracker-github/gitlab/local, triage-labels, domain.md. Run **once per target repo** before other tracker skills |
| `to-spec` | `skills/engineering/to-spec/SKILL.md` | `User/prompts/skills/to-spec/SKILL.md` | Reads tracker config from `docs/agents/` (or whatever setup writes) |
| `to-tickets` | `skills/engineering/to-tickets/SKILL.md` | `User/prompts/skills/to-tickets/SKILL.md` | Tracer-bullet tickets + blocking edges |
| `triage` | `skills/engineering/triage/` | `User/prompts/skills/triage/` | + `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md` |
| `wayfinder` | `skills/engineering/wayfinder/SKILL.md` | `User/prompts/skills/wayfinder/SKILL.md` | Multi-session investigation map on tracker |

**Order for Phase E implement:** setup skill first, then the four consumers.
**Order for use in a repo:** run `setup-matt-pocock-skills` once → then
grill → to-spec → to-tickets → implement, or triage / wayfinder as on-ramps.

**Adaptation for global profile:**

- Keep skill names as upstream so cross-refs work (`setup-matt-pocock-skills`, etc.).
- Strip or rephrase host-only assumptions (Claude plugin paths); keep `gh` / local markdown flows.
- Ensure every “run setup if missing” pointer names the local skill folder.
- After E ships, **re-link** earlier skills that currently avoid tracker deps
  (`code-review` Spec axis may use issue tracker again when `docs/agents/issue-tracker.md` exists).

### Deferred (still)

| Skill | Notes |
|-------|--------|
| `ponytail-audit`, `ponytail-debt` | Fast-follow after C–E or when needed |
| `ask-skills` | Only if discoverability hurts despite README |

### Explicitly skipped (do not port)

| Skill | Why |
|-------|-----|
| `ponytail-gain`, `ponytail-help` | Scoreboard / command card |
| `teach` | Teaching workspace, out of scope |
| `prototype` | Optional later; not approved this round |
| `improve-codebase-architecture` | Optional later; `codebase-design` covers vocabulary |
| CLI hooks / marketplace plugins | Wrong install model for this repo |

---

## Approved next phases (C–E)

Implement in this order unless you only need a subset:

```text
Phase C  grill family (grilling, domain-modeling, grill-me, thin grill-with-docs)
   ↓
Phase D  tdd + implement
   ↓
Phase E  setup-matt-pocock-skills → to-spec, to-tickets, triage, wayfinder
   ↓
Then: README catalog + handoff suggested-skills list + re-verify cross-refs
Optional later: ponytail-audit / ponytail-debt
```

### Phase C steps (checklist)

1. Fetch matt @ pinned tag (see §1).
2. Port `grilling/SKILL.md` (near-verbatim; MIT + Source footer).
3. Port `domain-modeling/` (`SKILL.md`, `CONTEXT-FORMAT.md`, `ADR-FORMAT.md`).
   Prefer upstream formats; diff against current `grill-with-docs/*-FORMAT.md`
   and keep any local improvements that still apply.
4. Port `grill-me` as thin wrapper: run `grilling`.
5. Replace `grill-with-docs/SKILL.md` with thin wrapper: run `grilling` +
   `domain-modeling`. Delete `grill-with-docs/CONTEXT-FORMAT.md` and
   `ADR-FORMAT.md` after formats live under `domain-modeling/`.
6. Grep for broken relative links to old format paths.
7. Update README + handoff suggested skills.
8. Log run.

### Phase D steps (checklist)

1. Port `tdd/` fully (`SKILL.md`, `tests.md`, `mocking.md`).
2. Light-adapt for house style: tagged unions OK; don’t push interface/class
   testing patterns; seams language should match `codebase-design` (public surface
   over free functions + data) where it mentions modules.
3. Port `implement/SKILL.md`; wire to `tdd`, `code-review`; optional
   `ponytail-review`; if Phase E not done yet, say tracker skills optional /
   run setup when available.
4. Confirm always-on instructions still say tests-after by default (no forced TDD).
5. README + handoff list; log run.

### Phase E steps (checklist)

1. Port entire `setup-matt-pocock-skills/` folder.
2. Port `to-spec`, `to-tickets`, `triage/` (with support files), `wayfinder`.
3. Strip dangling refs to un-ported skills only (`ask-matt`, `prototype`,
   `improve-codebase-architecture`, `ponytail-gain`, etc.).
4. Keep refs among ported skills (`tdd`, `implement`, `grill-with-docs`, setup, …).
5. Optionally tighten `code-review` Spec axis to use setup’s issue-tracker doc
   when present (restore upstream-style fetch when configured).
6. README: document “run setup once per repo” for tracker skills.
7. Verify: no skill points at missing `docs/agents/issue-tracker.md` without
   telling the user to run setup.
8. Log run.

---

## Repeatable process (re-port when upstreams update)

### 0. Preconditions

- Working tree clean enough to review a focused diff.
- Read pinned decisions in this file.
- Note current local skill list: `ls User/prompts/skills/`.

### 1. Fetch pinned upstreams

```bash
TMP=$(mktemp -d)
git clone --depth 1 --branch v1.1.0 https://github.com/mattpocock/skills.git "$TMP/matt"
# or: clone main / newer tag when intentionally upgrading
git clone --depth 1 https://github.com/DietrichGebert/ponytail.git "$TMP/pony"

echo "matt: $(git -C "$TMP/matt" rev-parse --short HEAD) $(git -C "$TMP/matt" describe --tags 2>/dev/null)"
echo "pony: $(git -C "$TMP/pony" rev-parse --short HEAD) $(git -C "$TMP/pony" describe --tags 2>/dev/null || true)"
# record versions in Run log below
```

For ponytail, pin a release tag when available (`git clone --branch vX.Y.Z …`).

### 2. Diff upstream skill bodies against local

For each skill in the inventory (A–E as they exist locally):

```bash
# Example
diff -u User/prompts/skills/ponytail/SKILL.md \
  "$TMP/pony/skills/ponytail/SKILL.md" | less

diff -u User/prompts/skills/tdd/SKILL.md \
  "$TMP/matt/skills/engineering/tdd/SKILL.md" | less
```

Classify each change:

| Class | Action |
|-------|--------|
| **House adaptation** | Keep ladder, DOD block, conflict order, DOD-primary review, procedural codebase-design |
| **Upstream improvement** | Merge into local, re-apply adaptations |
| **New upstream dependency** on skipped skills | Strip or rewrite |
| **New skill we want** | Add to inventory only after explicit approval |

### 3. Re-apply adaptation checklist (every skill)

- [ ] Frontmatter: `name`, `description`, optional `license: MIT`
- [ ] Body footer: `Source:` URL + MIT notice
- [ ] **No** `disable-model-invocation` unless verified for VS Code
- [ ] Cross-refs: only point at skills we ship (or setup → “run setup”)
- [ ] **Do not strip** refs to ported skills: `grilling`, `domain-modeling`,
  `grill-me`, `grill-with-docs`, `tdd`, `implement`, `to-spec`, `to-tickets`,
  `triage`, `wayfinder`, `setup-matt-pocock-skills`, `code-review`, `ponytail`, etc.
- [ ] **Do strip** refs to skipped skills: `ask-matt`, `prototype`,
  `improve-codebase-architecture`, `ponytail-gain`, `ponytail-help`, `teach`
- [ ] `ponytail`: adapted ladder + house rules + DOD + conflict order
- [ ] `ponytail-review`: DOD inverse tags
- [ ] `code-review`: DOD-primary Standards; optional complexity → `ponytail-review`
- [ ] `codebase-design`: plain data + free functions
- [ ] `tdd` / `implement`: opt-in TDD; agreed seams; no always-on force
- [ ] Tracker skills: depend on setup output paths consistently
- [ ] `research`: subagent if available, else inline
- [ ] `handoff` suggested skills: full list of skills we ship
- [ ] Always-on ladder + conflict order still match `ponytail` skill

### 4. Always-on instructions

Edit `User/prompts/copilot-instructions.md` only when philosophy changes:

1. Keep non-negotiables at top.
2. Keep **Laziness ladder** + **When rules conflict (full order)**.
3. Keep tests-after default; TDD remains skill-scoped.
4. Point at `beautiful-code.md` correctly.

### 5. README

Update skills catalog + Credits (upstream versions/SHAs) after every phase that
adds skills. Document setup-once for tracker suite after Phase E.

### 6. Verify

```bash
# Frontmatter shape
rg -n '^---' -A6 User/prompts/skills/*/SKILL.md

# Refs to skills we intentionally skip (should be zero or only in "do not use" notes)
rg -n 'ask-matt|/prototype|improve-codebase-architecture|/ponytail-gain|/ponytail-help' \
  User/prompts/skills/ || true

# After Phase C: formats live under domain-modeling; grill-with-docs is thin
ls User/prompts/skills/domain-modeling/
head -20 User/prompts/skills/grill-with-docs/SKILL.md
head -20 User/prompts/skills/grill-me/SKILL.md

# List skills
ls -1 User/prompts/skills/
```

Manual:

- [ ] Each skill folder has `SKILL.md` with `name` + `description`
- [ ] `codebase-design` has no class-hierarchy / “replace switch with polymorphism” as goal
- [ ] Ladder matches `ponytail` skill
- [ ] After C: no duplicate format files under `grill-with-docs/`
- [ ] After D: always-on still tests-after by default
- [ ] After E: setup skill present; consumers tell user to run it if config missing
- [ ] Sync `User/` → VS Code profile, reload, skills appear

### 7. Record the run

Append a section to [Run log](#run-log) with date, upstream SHAs/tags, phase
letter(s), what changed, who ran it.

### 8. Clean up

```bash
rm -rf "$TMP"
```

---

## Adaptation recipes (copy when re-porting)

### Ponytail ladder (canonical text for skill + always-on)

1. YAGNI — skip if not needed  
2. Already in this codebase — reuse  
3. Stdlib / language builtin — use it  
4. Native platform feature — use it  
5. Already-vendored dependency — use it. **Default: do not add a new dependency**; prefer hand-rolling a small piece. Exceptions: stdlib/builtins and small focused battle-tested packages (crypto / serialization class), or when the user explicitly asks.  
6. One line — if correct algorithm (subordinate to conflict order)  
7. Minimum that works  

### Conflict order (canonical)

1. Correctness / safety / trust boundaries / data-loss handling  
2. Real performance of work that matters (may be “clever”)  
3. Fewest lines / files / no unrequested abstraction  
4. Clever without measurable or structural advantage → reject  

### DOD inverse tags for `ponytail-review`

- `layout:` — lean line count but wrong data layout / cache-hostile hot path  
- Do not flag idiomatic hot-path tricks that pay for themselves with a short *why* comment  

### Grill family shape (Phase C+)

```text
grilling          ← interview loop only
domain-modeling   ← CONTEXT.md + ADRs (+ format files)
grill-me          ← “run grilling”
grill-with-docs   ← “run grilling + domain-modeling”
```

### Main engineering flow (after C–E)

```text
setup-matt-pocock-skills   (once per target repo)
        ↓
grill-with-docs  (or grill-me if no codebase)
        ↓
to-spec → to-tickets → implement  (tdd at seams → code-review)
   or triage / wayfinder as on-ramps
```

Standalone: `tdd`, `diagnosing-bugs`, `ponytail` / `ponytail-review`, `research`,
`handoff`, `codebase-design`.

---

## Run log

### 2026-07-09 — initial Phase A + B implementation

| Field | Value |
|-------|--------|
| Operator | Grok (agent) |
| mattpocock/skills | tag **v1.1.0**, SHA `d574778f94cf620fcc8ce741584093bc650a61d3` |
| DietrichGebert/ponytail | main ~**4.8.4**, SHA `523e9dc051a073a85592e74c1f292ac93e3633da` |
| Plan docs | `grok_plan.md`, `claude_plan.md` |

**Steps taken**

1. Cloned both upstreams shallow into `/tmp`.  
2. Inventoried skill files and supporting assets.  
3. Updated `User/prompts/copilot-instructions.md` (ladder + full conflict order).  
4. Wrote adapted skills: `ponytail`, `ponytail-review`, `diagnosing-bugs` (+ HITL script), `handoff`.  
5. Wrote Phase B: `code-review`, `research`, `writing-great-skills` (+ GLOSSARY), `codebase-design` (+ DEEPENING, DESIGN-IT-TWICE adapted).  
6. Fixed `beautiful-code.md` companion path.  
7. Updated `README.md` catalog + Credits.  
8. Verified frontmatter and grepped for dangling refs.  
9. Authored this playbook.

**Shipped:** Phase A + B.  
**Then deferred (later revised):** see next log entry.

### 2026-07-09 — scope revision (playbook only; no skill ports)

| Field | Value |
|-------|--------|
| Operator | Grok (agent) |
| Trigger | User approved skills previously marked skip |

**Decision changes**

| Was | Now |
|-----|-----|
| Keep `grill-with-docs` monolithic; skip split | **Phase C:** port `grilling`, `domain-modeling`, `grill-me`; thin `grill-with-docs` |
| Skip `tdd` / `implement` | **Phase D:** port both (TDD opt-in; always-on stays tests-after) |
| Skip tracker suite | **Phase E:** port `setup-matt-pocock-skills`, `to-spec`, `to-tickets`, `triage`, `wayfinder` |
| Still skip | `ponytail-gain`/`help`, `teach`, `prototype`, `improve-codebase-architecture`, CLI hooks |
| Still defer | `ponytail-audit`/`debt`, `ask-skills` |

**Steps taken**

1. Updated this playbook: pinned decisions, inventory Phases C–E, checklists, flow diagram, verify rules for cross-refs among ported skills.  
2. **Did not implement** C–E in this run — playbook update only.

**Next run:** implement Phase C (then D, then E) per checklists above; append a new run-log section when done.
