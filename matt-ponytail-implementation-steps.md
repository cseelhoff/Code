# Matt + Ponytail → Copilot profile: implementation playbook

Repeatable process for vendoring selected skills from
[mattpocock/skills](https://github.com/mattpocock/skills) and
[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) into this
repo (`agents/skills/` + always-on instruction files). Use this when either
upstream releases updates you want to re-port, or when re-running a phase.

**Design authority:** `grok_plan.md` + `claude_plan.md` (base philosophy) +
**this file** for phase status and re-port procedure.  
**Status:** Phases **A–E implemented**. Layout: skills live under **`agents/skills/`** (install → `~/.agents/skills/` for Copilot + Grok). See [Layout](#layout-copilot--grok).

---

## Layout (Copilot + Grok)

Research (VS Code docs + Grok user guide + xAI docs):

| Artifact | Repo path | Personal install |
|----------|-----------|------------------|
| Skills | `agents/skills/<name>/` | `~/.agents/skills/` (Copilot **and** Grok) |
| Copilot always-on | `User/prompts/copilot-instructions.md` | VS Code profile `User/prompts/` |
| Grok always-on | `AGENTS.md` | `~/.grok/AGENTS.md` (or project root) |
| Style source of truth | `shared/coding-style.md` | run `scripts/sync-instructions.sh` after edits |

**Not a skill path:** `User/prompts/skills/` — Copilot does not discover skills there.

When re-porting skills, write under `agents/skills/`, not under `User/prompts/`.

---

## Pinned decisions (do not re-litigate on re-port)

| Topic | Decision |
|-------|----------|
| Ladder rung 5 | Soft default: already-vendored OK; prefer hand-roll; stdlib/builtins + battle-tested focused packages OK; **new** dep only on explicit request or unbeatable-package case |
| Boring vs clever | Conflict order: correctness → real performance → minimalism → clever-without-payoff rejected |
| Always-on tests stance | Prefer tests **after** code for normal work (`copilot-instructions.md`). **`tdd` is opt-in** when the user invokes it or when `implement` drives red-green at agreed seams |
| `grill-with-docs` | **Split shape (done):** thin wrapper = `grilling` + `domain-modeling` |
| `grill-me` | **Done** — grilling without docs |
| `grilling` + `domain-modeling` | **Done** — formats under `domain-modeling/` |
| `tdd` / `implement` | **Done** — TDD opt-in; always-on stays tests-after |
| Tracker suite | **Done:** `setup-matt-pocock-skills`, `to-spec`, `to-tickets`, `triage`, `wayfinder` |
| `code-review` Standards | DOD-primary (`copilot-instructions.md` + `beautiful-code.md`); Fowler secondary, heavily filtered |
| `codebase-design` | Heavily adapted (plain data + free functions) — already shipped |
| `ponytail-audit` / `ponytail-debt` | Still deferred (after C–E or when audit pain appears) |
| `ask-skills` | Still deferred (README catalog first) |
| Still skip | `ponytail-gain`, `ponytail-help`, `teach`, `prototype`, `improve-codebase-architecture`, Copilot CLI hooks/plugins, personal/misc Matt skills |
| Frontmatter | Ship `name` + `description`; `license: MIT`; put `Source:` in body. `disable-model-invocation` is supported by VS Code Copilot and Grok — use when a skill should be slash-only |
| Layout | Skills under `agents/skills/<name>/` (install → `~/.agents/skills/`) |

---

## Skill inventory

### Phase A (core) — **done**

| Skill | Upstream path | Local path |
|-------|---------------|------------|
| (always-on ladder) | ponytail ladder | `User/prompts/copilot-instructions.md` |
| `ponytail` | `skills/ponytail/SKILL.md` | `agents/skills/ponytail/SKILL.md` |
| `ponytail-review` | `skills/ponytail-review/SKILL.md` | `agents/skills/ponytail-review/SKILL.md` |
| `diagnosing-bugs` | `skills/engineering/diagnosing-bugs/` | `agents/skills/diagnosing-bugs/` |
| `handoff` | `skills/productivity/handoff/SKILL.md` | `agents/skills/handoff/SKILL.md` |
| path fix | — | `beautiful-code.md` header |

### Phase B (workflow) — **done**

| Skill | Upstream path | Local path |
|-------|---------------|------------|
| `code-review` | `skills/engineering/code-review/SKILL.md` | `agents/skills/code-review/SKILL.md` |
| `research` | `skills/engineering/research/SKILL.md` | `agents/skills/research/SKILL.md` |
| `writing-great-skills` | `skills/productivity/writing-great-skills/` | `agents/skills/writing-great-skills/` |
| `codebase-design` | `skills/engineering/codebase-design/` | `agents/skills/codebase-design/` |

### Phase C (grill family) — **done**

| Skill | Upstream path | Local path |
|-------|---------------|------------|
| `grilling` | `skills/productivity/grilling/SKILL.md` | `agents/skills/grilling/SKILL.md` |
| `domain-modeling` | `skills/engineering/domain-modeling/` | `agents/skills/domain-modeling/` (+ formats) |
| `grill-me` | `skills/productivity/grill-me/SKILL.md` | `agents/skills/grill-me/SKILL.md` |
| `grill-with-docs` | thin wrapper | `agents/skills/grill-with-docs/SKILL.md` only |

### Phase D (build loop) — **done**

| Skill | Upstream path | Local path |
|-------|---------------|------------|
| `tdd` | `skills/engineering/tdd/` | `agents/skills/tdd/` |
| `implement` | `skills/engineering/implement/SKILL.md` | `agents/skills/implement/SKILL.md` |

**House rule:** default coding = tests after; `tdd` / `implement` red-green is opt-in at agreed seams.

### Phase E (tracker suite) — **done**

| Skill | Upstream path | Local path |
|-------|---------------|------------|
| `setup-matt-pocock-skills` | `skills/engineering/setup-matt-pocock-skills/` | `agents/skills/setup-matt-pocock-skills/` |
| `to-spec` | `skills/engineering/to-spec/SKILL.md` | `agents/skills/to-spec/SKILL.md` |
| `to-tickets` | `skills/engineering/to-tickets/SKILL.md` | `agents/skills/to-tickets/SKILL.md` |
| `triage` | `skills/engineering/triage/` | `agents/skills/triage/` |
| `wayfinder` | `skills/engineering/wayfinder/SKILL.md` | `agents/skills/wayfinder/SKILL.md` |

**Use order in a target repo:** `setup-matt-pocock-skills` once → grill → to-spec → to-tickets → implement (or triage / wayfinder).

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

## Phase C–E checklists (for re-port / re-run)

Use when re-porting after upstream updates. First implementation completed 2026-07-09.

### Phase C

1. Port `grilling`, `domain-modeling/` (with formats), thin `grill-me` + `grill-with-docs`.
2. Formats only under `domain-modeling/`; no format files under `grill-with-docs/`.
3. MIT + Source footers; no `disable-model-invocation`.

### Phase D

1. Port `tdd/` (`SKILL.md`, `tests.md`, `mocking.md`) with DOD / public-surface language.
2. Port `implement` → `tdd` at seams, `code-review`, optional `ponytail-review`.
3. Always-on remains tests-after by default.

### Phase E

1. Port `setup-matt-pocock-skills/` + `to-spec`, `to-tickets`, `triage/`, `wayfinder`.
2. Strip refs to skipped skills (`improve-codebase-architecture`, dedicated `/prototype` skill, etc.).
3. Keep setup pointers; `code-review` may use `docs/agents/issue-tracker.md` when present.

Optional later: `ponytail-audit` / `ponytail-debt`.

---

## Repeatable process (re-port when upstreams update)

### 0. Preconditions

- Working tree clean enough to review a focused diff.
- Read pinned decisions in this file.
- Note current local skill list: `ls agents/skills/`.

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
diff -u agents/skills/ponytail/SKILL.md \
  "$TMP/pony/skills/ponytail/SKILL.md" | less

diff -u agents/skills/tdd/SKILL.md \
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
rg -n '^---' -A6 agents/skills/*/SKILL.md

# Refs to skills we intentionally skip (should be zero or only in "do not use" notes)
rg -n 'ask-matt|/prototype|improve-codebase-architecture|/ponytail-gain|/ponytail-help' \
  agents/skills/ || true

# After Phase C: formats live under domain-modeling; grill-with-docs is thin
ls agents/skills/domain-modeling/
head -20 agents/skills/grill-with-docs/SKILL.md
head -20 agents/skills/grill-me/SKILL.md

# List skills
ls -1 agents/skills/
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

**Next run:** implemented in following entry.

### 2026-07-09 — Phase C → D → E implementation

| Field | Value |
|-------|--------|
| Operator | Grok (agent) |
| mattpocock/skills | tag **v1.1.0**, SHA `d574778f94cf620fcc8ce741584093bc650a61d3` |

**Phase C**

1. Ported `grilling`, `domain-modeling` (+ CONTEXT/ADR formats), thin `grill-me`.
2. Replaced monolithic `grill-with-docs` with thin wrapper; removed format files from that folder.

**Phase D**

1. Ported `tdd` (+ `tests.md`, `mocking.md`) — opt-in; public-surface / DOD language.
2. Ported `implement` — tdd at seams, code-review, optional ponytail-review; tests-after escape hatch.

**Phase E**

1. Ported `setup-matt-pocock-skills` (full seed docs).
2. Ported `to-spec`, `to-tickets`, `triage` (+ AGENT-BRIEF, OUT-OF-SCOPE), `wayfinder`.
3. Stripped `disable-model-invocation`; removed improve-codebase / dedicated prototype skill deps; fixed stray `</content>` on to-tickets.
4. Relinked `code-review` Spec axis to `docs/agents/issue-tracker.md` when setup has been run.

**Meta**

1. Updated `handoff` suggested-skills list and `README.md` catalog.
2. Updated this playbook status and inventory to A–E done.

**Still deferred:** `ponytail-audit`, `ponytail-debt`, `ask-skills`.  
**Still skipped:** gain/help, teach, prototype skill, improve-codebase-architecture, CLI hooks.

### 2026-07-09 — layout restructure (agents/skills + dual-agent install)

| Field | Value |
|-------|--------|
| Operator | Grok (agent) |
| Trigger | Research Copilot + Grok skill paths; merge-conflict origin README |

**Findings**

- Copilot personal skills: `~/.agents/skills/`, `~/.copilot/skills/`, `~/.claude/skills/` (not `User/prompts/skills/`).
- Grok personal skills: `~/.grok/skills/` and **`~/.agents/skills/`** (also project `.agents/skills/`, `.grok/skills/`).
- Shared personal skill root for both: **`~/.agents/skills/`**.
- Always-on: Copilot → profile instructions; Grok → `AGENTS.md` / `~/.grok/`.

**Steps taken**

1. `git mv User/prompts/skills` → `agents/skills`.
2. Added `shared/coding-style.md` as source of truth; `scripts/sync-instructions.sh`.
3. Synced `User/prompts/copilot-instructions.md` + root `AGENTS.md`.
4. Rewrote `README.md` (layout, Windows/Linux install, Grok install, project-local).
5. Updated playbook/plan path strings to `agents/skills/`.

**Resolves origin conflict intent:** origin README documented `agents/` → `~/.agents` but never moved files; this run implements that layout fully and keeps the local skill suite.
