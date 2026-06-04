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

### Stable VS Code

Use the `Code` folder instead of `Code - Insiders`:

```powershell
git clone https://github.com/cseelhoff/Code "$env:TEMP\copilot-config"
Copy-Item "$env:TEMP\copilot-config\User\*" "$env:APPDATA\Code\User" -Recurse -Force
Remove-Item "$env:TEMP\copilot-config" -Recurse -Force
```

## Install by cloning directly into place

To keep the config under version control in place (so you can `git pull` updates),
clone straight into the user-data directory. This only works cleanly on a fresh
profile where a `prompts` folder doesn't already exist:

```powershell
git clone https://github.com/cseelhoff/Code "$env:APPDATA\Code - Insiders\User\Code-config"
```

Then point VS Code at the cloned `prompts` folder, or symlink it:

```powershell
New-Item -ItemType SymbolicLink `
  -Path "$env:APPDATA\Code - Insiders\User\prompts" `
  -Target "$env:APPDATA\Code - Insiders\User\Code-config\User\prompts"
```

> Run the symlink command from an elevated (Administrator) PowerShell, or enable
> Windows Developer Mode, since creating symlinks requires the privilege.

After installing, restart VS Code so Copilot picks up the new instructions and skills.
