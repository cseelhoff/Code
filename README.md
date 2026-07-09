# Code

My GitHub Copilot configuration for VS Code — custom instructions and skills,
kept in version control so they can be dropped into a fresh install.

Philosophy: **data-oriented, procedural, performance-first**, with a **laziness
ladder** (YAGNI → reuse → stdlib → native → vendored deps → minimum) that never
overrides real hot-path performance. See `User/prompts/copilot-instructions.md`
and `beautiful-code.md`.

## Repository layout

```
.
├── User/
│   └── prompts/
│       ├── copilot-instructions.md   # global always-on custom instructions
│       └── skills/                   # Copilot skills (one folder per skill)
│           ├── grill-with-docs/
│           ├── ponytail/
│           ├── ponytail-review/
│           ├── diagnosing-bugs/
│           ├── handoff/
│           ├── code-review/
│           ├── research/
│           ├── writing-great-skills/
│           └── codebase-design/
├── beautiful-code.md                 # slop-vs-lean performance examples (Odin)
├── grok_plan.md                      # integration design (refined)
├── claude_plan.md                    # peer plan + interview locks
└── matt-ponytail-implementation-steps.md  # re-port playbook when upstreams update
```

The `User/` folder mirrors VS Code's user-data `User/` directory, so its contents
map directly onto your profile.

## Skills catalog

| Skill | When to use |
|-------|-------------|
| **grill-with-docs** | Relentless design interview; grow `CONTEXT.md` + ADRs in the target repo |
| **ponytail** | Lazy senior mode (lite/full/ultra): minimize what you build |
| **ponytail-review** | Diff review for over-engineering + lean-but-wrong layout |
| **diagnosing-bugs** | Hard bugs / perf regressions: tight loop → hypothesise → fix |
| **handoff** | Compact the chat for a fresh session |
| **code-review** | Standards (DOD-primary) + Spec axes since a fixed git point |
| **research** | Primary-source investigation → cited Markdown note |
| **writing-great-skills** | Author/edit skills in this library |
| **codebase-design** | Deep modules as data + free functions (vocabulary + deepening) |

**Shipped:** Phase A + B (see catalog above).

**Approved next** (not installed yet — see `matt-ponytail-implementation-steps.md`):

- **Phase C:** `grilling`, `domain-modeling`, `grill-me`; thin `grill-with-docs`
- **Phase D:** `tdd`, `implement`
- **Phase E:** `setup-matt-pocock-skills`, `to-spec`, `to-tickets`, `triage`, `wayfinder`

**Still deferred:** `ponytail-audit`, `ponytail-debt`, local skill router.

**Skipped for now:** `ponytail-gain`/`help`, `teach`, `prototype`,
`improve-codebase-architecture`, Copilot CLI hooks.

## Install (Windows, VS Code Insiders)

VS Code Insiders stores user config in `%APPDATA%\Code - Insiders\User`.
Clone this repo into a temp location and copy the `User` folder over the top:

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code - Insiders\User" -Recurse -Force
Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

### Stable VS Code

Use the `Code` folder instead of `Code - Insiders`:

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code\User" -Recurse -Force
Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

After installing, restart VS Code so Copilot picks up the new instructions and skills.

## Updating from upstreams

When [mattpocock/skills](https://github.com/mattpocock/skills) or
[ponytail](https://github.com/DietrichGebert/ponytail) change, follow
**`matt-ponytail-implementation-steps.md`** — fetch, diff each skill, re-apply
house adaptations, verify, log the run.

## Credits

Skills adapted from (MIT licensed):

| Upstream | Version used in last port | Skills |
|----------|---------------------------|--------|
| [mattpocock/skills](https://github.com/mattpocock/skills) | **v1.1.0** (`d574778`) | diagnosing-bugs, handoff, code-review, research, writing-great-skills, codebase-design |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | **~4.8.4** (`523e9dc`) | ponytail, ponytail-review; ladder also folded into always-on instructions |

Each skill body includes a `Source:` line. House adaptations (DOD, hand-roll
dependency rung, performance conflict order) are documented in `grok_plan.md`
and the playbook.
