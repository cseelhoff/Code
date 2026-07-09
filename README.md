# Code — portable agent profile (Copilot + Grok Build)

Personal AI coding configuration: **always-on style** + **Agent Skills**, kept in
git so you can install into GitHub Copilot (VS Code) and/or Grok Build.

## Research: where skills and instructions live

### GitHub Copilot (VS Code) — official locations

| Kind | Paths |
|------|--------|
| **Personal skills** | `~/.agents/skills/`, `~/.copilot/skills/`, `~/.claude/skills/` |
| **Project skills** | `.agents/skills/`, `.github/skills/`, `.claude/skills/` |
| **Custom instructions** | VS Code profile `User/prompts/copilot-instructions.md` (and repo `.github/copilot-instructions.md`) |

Sources: [VS Code Agent Skills](https://code.visualstudio.com/docs/agent-customization/agent-skills),
[GitHub docs — add skills](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills).

**`User/prompts/skills/` is not a Copilot skill discovery path.** Skills there are ignored.
Instructions/prompts belong under the profile `User/prompts/`; skills belong under
`~/.agents/skills/` (or project `.agents/skills/`).

### Grok Build — official locations

| Kind | Paths |
|------|--------|
| **Personal skills** | `~/.grok/skills/`, also **`~/.agents/skills/`**, `~/.claude/skills/` |
| **Project skills** | `./.grok/skills/`, **`.agents/skills/`** (walked to repo root) |
| **Always-on rules** | `AGENTS.md` family (cwd → repo root); global under `~/.grok/` |

Sources: [xAI — Skills, plugins](https://docs.x.ai/build/features/skills-plugins-marketplaces),
local Grok user guide `~/.grok/docs/user-guide/08-skills.md` and `12-project-rules.md`.

### Shared personal install (both tools)

| Artifact | Repo path | Installs to |
|----------|-----------|-------------|
| Skills | `agents/skills/` | **`~/.agents/skills/`** — discovered by **Copilot and Grok** |
| Copilot instructions | `User/prompts/copilot-instructions.md` | VS Code `User/prompts/` |
| Grok always-on | `AGENTS.md` | **`~/.grok/AGENTS.md`** (global) or project root |
| Style source of truth | `shared/coding-style.md` | synced into the two instruction files |

Optional Grok-only: also copy skills to `~/.grok/skills/` if you prefer Grok’s
native path; not required if `~/.agents/skills/` is populated.

---

## Repository layout

```
.
├── agents/
│   └── skills/                 # → ~/.agents/skills/  (Copilot + Grok)
│       ├── grill-with-docs/
│       ├── ponytail/
│       └── …                   # one folder per skill (SKILL.md + extras)
├── User/
│   └── prompts/
│       └── copilot-instructions.md   # → VS Code User/prompts/
├── AGENTS.md                   # → ~/.grok/AGENTS.md  (Grok always-on)
├── shared/
│   └── coding-style.md         # single source for always-on body
├── scripts/
│   └── sync-instructions.sh    # rebuild instruction files from shared/
├── beautiful-code.md           # slop-vs-lean examples (attach when needed)
├── matt-ponytail-implementation-steps.md
├── grok_plan.md
└── claude_plan.md
```

Philosophy: **data-oriented, procedural, performance-first**, plus a **laziness
ladder** that never overrides real hot-path performance. Default tests are
**after** code; use **`tdd`** / **`implement`** for red-green.

Edit always-on style in **`shared/coding-style.md`**, then run:

```sh
./scripts/sync-instructions.sh
```

---

## Skills catalog

### Align & domain

| Skill | When to use |
|-------|-------------|
| **grill-with-docs** | Grill + grow `CONTEXT.md` / ADRs |
| **grill-me** | Grill only (no docs) |
| **grilling** | Interview primitive |
| **domain-modeling** | Glossary + ADRs |

### Plan on a tracker

| Skill | When to use |
|-------|-------------|
| **setup-matt-pocock-skills** | Once per target repo |
| **to-spec** | Conversation → spec |
| **to-tickets** | Spec → tracer tickets |
| **triage** | Incoming issues/PRs |
| **wayfinder** | Multi-session investigation map |

### Build & review

| Skill | When to use |
|-------|-------------|
| **implement** | Spec/tickets → build → review |
| **tdd** | Opt-in red-green |
| **code-review** | Standards + Spec |
| **ponytail** / **ponytail-review** | Minimize / hunt complexity |
| **diagnosing-bugs** | Hard bugs / perf |
| **codebase-design** | Deep modules (data + free functions) |

### Meta

| Skill | When to use |
|-------|-------------|
| **handoff** | Fresh session handoff |
| **research** | Primary-source notes |
| **writing-great-skills** | Author skills |

### Main flow (in a target repo)

```text
setup-matt-pocock-skills   (once)
  → grill-with-docs
  → to-spec → to-tickets → implement
```

**Deferred:** `ponytail-audit`, `ponytail-debt`, skill router.  
**Skipped:** gain/help, teach, prototype skill, improve-codebase-architecture, CLI hooks.

---

## Install

### Windows — VS Code Insiders + personal skills (Copilot)

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"

# Always-on instructions → VS Code profile
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code - Insiders\User" -Recurse -Force

# Skills → ~/.agents (Copilot + Grok personal discovery)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
Copy-Item "$env:TEMP\copilot-config\agents\skills\*" "$env:USERPROFILE\.agents\skills" -Recurse -Force

Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

### Windows — Stable VS Code

Same as above, but use `$env:APPDATA\Code\User` instead of `Code - Insiders`.

### Linux — VS Code Insiders + skills

```sh
tmpdir="$(mktemp -d)"
git clone https://github.com/cseelhoff/Code "$tmpdir/copilot-config"

mkdir -p "$HOME/.config/Code - Insiders/User"
cp -a "$tmpdir/copilot-config/User/." "$HOME/.config/Code - Insiders/User/"

mkdir -p "$HOME/.agents/skills"
cp -a "$tmpdir/copilot-config/agents/skills/." "$HOME/.agents/skills/"

rm -rf "$tmpdir"
```

Stable Linux: use `"$HOME/.config/Code/User"` instead of `Code - Insiders`.

### Grok Build (always-on + skills)

Skills are already covered if you installed to `~/.agents/skills/`. Add global rules:

```sh
# From a clone of this repo:
mkdir -p "$HOME/.grok"
cp AGENTS.md "$HOME/.grok/AGENTS.md"
# Skills (if not already in ~/.agents/skills):
mkdir -p "$HOME/.agents/skills"
cp -a agents/skills/. "$HOME/.agents/skills/"
```

Optional: also copy skills to `~/.grok/skills/` for Grok-native layout only.

### Project-local install (one repo only)

```sh
# In the target project root:
mkdir -p .agents/skills
cp -a /path/to/Code/agents/skills/. .agents/skills/
cp /path/to/Code/AGENTS.md ./AGENTS.md   # Grok + other AGENTS.md readers
# Copilot project instructions (optional):
mkdir -p .github
cp User/prompts/copilot-instructions.md .github/copilot-instructions.md
```

Restart VS Code / start a new Grok session after installing.

---

## Updating skills from upstreams

See **`matt-ponytail-implementation-steps.md`** (paths use `agents/skills/`).

---

## Credits

| Upstream | Version | What |
|----------|---------|------|
| [mattpocock/skills](https://github.com/mattpocock/skills) | v1.1.0 (`d574778`) | Engineering + productivity skills |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | ~4.8.4 (`523e9dc`) | ponytail + review; ladder in always-on |

Each skill includes a `Source:` line. House adaptations (DOD, hand-roll deps, performance conflict order) are documented in the playbook.
