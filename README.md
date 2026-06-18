# Code

My GitHub Copilot configuration for VS Code — custom instructions and skills, kept in version control so they can be dropped into a fresh install.

## Repository layout

```
.
├── User/
│   └── prompts/
│       ├── copilot-instructions.md   # global custom instructions
│       └── skills/                   # Copilot skills (one folder per skill)
│           └── grill-with-docs/
│               ├── SKILL.md
│               ├── CONTEXT-FORMAT.md
│               └── ADR-FORMAT.md
└── beautiful-code.md
```

The `User/` folder mirrors VS Code's user-data `User/` directory, so its contents
map directly onto your profile.

## Install (Windows, VS Code Insiders)

VS Code Insiders stores user config in `%APPDATA%\Code - Insiders\User`.
Clone this repo into a temp location and copy the `User` folder over the top:

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code - Insiders\User" -Recurse -Force
Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

Linux
```sh
tmpdir="$(mktemp -d)"
git clone https://github.com/cseelhoff/Code "$tmpdir/copilot-config"
mkdir -p "$HOME/.config/Code - Insiders/User"
cp -a "$tmpdir/copilot-config/User/." "$HOME/.config/Code - Insiders/User/"
rm -rf "$tmpdir"
```

### Stable VS Code

Use the `Code` folder instead of `Code - Insiders`:

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code\User" -Recurse -Force
Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

After installing, restart VS Code so Copilot picks up the new instructions and skills.
