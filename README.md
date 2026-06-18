# Code

My GitHub Copilot configuration for VS Code — custom instructions and skills, kept in version control so they can be dropped into a fresh install.

## Repository layout

```
.
├── User/
│   └── prompts/
│       └── copilot-instructions.md   # global custom instructions
├── agents/
│   └── skills/                       # Copilot skills (one folder per skill)
│       └── grill-with-docs/
│           ├── SKILL.md
│           ├── CONTEXT-FORMAT.md
│           └── ADR-FORMAT.md
└── beautiful-code.md                 # optional coding-style companion doc
```

The two top-level folders mirror their install destinations, so each maps
directly onto a target directory:

| Repo folder | Installs to | Holds |
|-------------|-------------|-------|
| `User/`   | VS Code user-data `User/` directory   | instructions, prompts, agents |
| `agents/` | `~/.agents/` in your home directory   | skills |

> **Why two locations?** Copilot Chat discovers skills from `~/.agents/skills/`
> (also `.github/skills/` and `.claude/skills/` inside a workspace) — **not**
> from the VS Code `User/prompts/` folder. Skills placed under `User/prompts/`
> are silently ignored. Instructions, prompts, and agents *do* live in the
> profile's `User/prompts/` folder. The `~/.agents/` location is shared across
> VS Code Stable and Insiders.

## Install (Windows, VS Code Insiders)

VS Code Insiders stores user config in `%APPDATA%\Code - Insiders\User`, and
skills live in `%USERPROFILE%\.agents`. Clone this repo into a temp location and
copy both folders to their destinations:

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"

# Instructions -> VS Code user profile
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code - Insiders\User" -Recurse -Force

# Skills -> ~/.agents (discovered by Copilot Chat)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents" | Out-Null
Copy-Item "$env:TEMP\copilot-config\agents\*" "$env:USERPROFILE\.agents" -Recurse -Force

Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

### Linux

```sh
tmpdir="$(mktemp -d)"
git clone https://github.com/cseelhoff/Code "$tmpdir/copilot-config"

# Instructions -> VS Code user profile
mkdir -p "$HOME/.config/Code - Insiders/User"
cp -a "$tmpdir/copilot-config/User/." "$HOME/.config/Code - Insiders/User/"

# Skills -> ~/.agents (discovered by Copilot Chat)
mkdir -p "$HOME/.agents"
cp -a "$tmpdir/copilot-config/agents/." "$HOME/.agents/"

rm -rf "$tmpdir"
```

### Stable VS Code

Skills go to the same `~/.agents` location; only the instructions destination
changes — use the `Code` folder instead of `Code - Insiders`:

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"

# Instructions -> VS Code user profile (Stable)
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code\User" -Recurse -Force

# Skills -> ~/.agents (shared across Stable and Insiders)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents" | Out-Null
Copy-Item "$env:TEMP\copilot-config\agents\*" "$env:USERPROFILE\.agents" -Recurse -Force

Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

After installing, restart VS Code so Copilot picks up the new instructions and skills.
