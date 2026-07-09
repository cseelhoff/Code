# Code

My GitHub Copilot configuration for VS Code — custom instructions and skills,
kept in version control so they can be dropped into a fresh install.

Philosophy: **data-oriented, procedural, performance-first**, with a **laziness
ladder** (YAGNI → reuse → stdlib → native → vendored deps → minimum) that never
overrides real hot-path performance. See `User/prompts/copilot-instructions.md`
and `beautiful-code.md`. Default tests are **after** code; use **`tdd`** /
**`implement`** when you want red-green.

## Repository layout

```
.
├── User/prompts/
│   ├── copilot-instructions.md
│   └── skills/                   # one folder per skill
├── beautiful-code.md
├── grok_plan.md
├── claude_plan.md
└── matt-ponytail-implementation-steps.md
```

The `User/` folder mirrors VS Code's user-data `User/` directory.

## Skills catalog

### Align & domain

| Skill | When to use |
|-------|-------------|
| **grill-with-docs** | Grill + grow `CONTEXT.md` / ADRs (`grilling` + `domain-modeling`) |
| **grill-me** | Grill only (no docs) |
| **grilling** | Interview primitive |
| **domain-modeling** | Glossary + ADRs (formats live here) |

### Plan on a tracker

| Skill | When to use |
|-------|-------------|
| **setup-matt-pocock-skills** | **Once per target repo** — tracker, triage labels, domain layout |
| **to-spec** | Conversation → spec on the tracker |
| **to-tickets** | Spec/plan → tracer-bullet tickets with blockers |
| **triage** | Incoming issues/PRs through triage roles |
| **wayfinder** | Multi-session investigation map on the tracker |

### Build & review

| Skill | When to use |
|-------|-------------|
| **implement** | Build from spec/tickets; TDD at agreed seams; then `code-review` |
| **tdd** | Explicit red-green loop (opt-in) |
| **code-review** | Standards (DOD-primary) + Spec since a fixed git point |
| **ponytail** | Lazy senior mode (lite/full/ultra) |
| **ponytail-review** | Over-engineering + lean-but-wrong layout |
| **diagnosing-bugs** | Hard bugs / perf regressions |
| **codebase-design** | Deep modules as data + free functions |

### Meta

| Skill | When to use |
|-------|-------------|
| **handoff** | Compact chat for a fresh session |
| **research** | Primary-source investigation → cited note |
| **writing-great-skills** | Author/edit skills in this library |

### Main flow (after setup in the target repo)

```text
setup-matt-pocock-skills   (once)
  → grill-with-docs
  → to-spec → to-tickets → implement  (tdd at seams → code-review)
  or triage / wayfinder as on-ramps
```

**Still deferred:** `ponytail-audit`, `ponytail-debt`, skill router.

**Skipped:** `ponytail-gain`/`help`, `teach`, `prototype`,
`improve-codebase-architecture`, Copilot CLI hooks.

## Install (Windows, VS Code Insiders)

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code - Insiders\User" -Recurse -Force
Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

### Stable VS Code

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code\User" -Recurse -Force
Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

Restart VS Code so Copilot picks up instructions and skills.

## Updating from upstreams

Follow **`matt-ponytail-implementation-steps.md`** when
[mattpocock/skills](https://github.com/mattpocock/skills) or
[ponytail](https://github.com/DietrichGebert/ponytail) change.

## Credits

| Upstream | Version (last full port) | Skills |
|----------|--------------------------|--------|
| [mattpocock/skills](https://github.com/mattpocock/skills) | **v1.1.0** (`d574778`) | grill family, domain-modeling, tdd, implement, setup, to-spec, to-tickets, triage, wayfinder, diagnosing-bugs, handoff, code-review, research, writing-great-skills, codebase-design |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | **~4.8.4** (`523e9dc`) | ponytail, ponytail-review; ladder in always-on instructions |

Each skill body includes a `Source:` line. House adaptations are in the playbook
and plan docs.
