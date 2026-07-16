# Install this agent-config profile for GitHub Copilot (VS Code / Insiders)
# and/or Grok Build on Windows.
#
# Usage (from repo root or scripts/):
#   .\scripts\install.ps1
#   .\scripts\install.ps1 -DryRun
#   .\scripts\install.ps1 -ForceAll
#   .\scripts\install.ps1 -SkillsOnly
#   .\scripts\install.ps1 -Vscode -VscodeInsiders -Grok
#   .\scripts\install.ps1 -GrokSkills
#
# Install map:
#   agents\skills\*  →  %USERPROFILE%\.agents\skills
#   User\prompts\*   →  %APPDATA%\Code\User\prompts  (and/or Code - Insiders)
#   AGENTS.md        →  %USERPROFILE%\.grok\AGENTS.md
#
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$ForceAll,
    [switch]$SkillsOnly,
    [switch]$Vscode,
    [switch]$VscodeInsiders,
    [switch]$Grok,
    [switch]$Skills,
    [switch]$GrokSkills,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Full
    exit 0
}

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$UserProfile = $env:USERPROFILE
if (-not $UserProfile) { $UserProfile = $env:HOME }
$AppData = $env:APPDATA
if (-not $AppData) { throw "APPDATA is not set (Windows profile required)" }

function Write-Info([string]$Message) { Write-Host "  $Message" }
function Write-Log([string]$Message)  { Write-Host $Message }
function Write-Warn([string]$Message) { Write-Warning $Message }

function Test-CommandExists([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-VscodeStable {
    if (Test-CommandExists "code") { return $true }
    $p = Join-Path $AppData "Code"
    return (Test-Path $p)
}

function Test-VscodeInsiders {
    if (Test-CommandExists "code-insiders") { return $true }
    $p = Join-Path $AppData "Code - Insiders"
    return (Test-Path $p)
}

function Test-Grok {
    if (Test-CommandExists "grok") { return $true }
    if (Test-CommandExists "grok-build") { return $true }
    $grokDir = Join-Path $UserProfile ".grok"
    if (Test-Path $grokDir) { return $true }
    if (Test-Path (Join-Path $grokDir "config.toml")) { return $true }
    return $false
}

function Invoke-Step {
    param([scriptblock]$Action, [string]$Description)
    if ($DryRun) {
        Write-Info "dry-run: $Description"
        return
    }
    & $Action
}

function Ensure-Dir([string]$Path) {
    Invoke-Step -Description "mkdir $Path" -Action {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Copy-Tree {
    param([string]$Source, [string]$Destination)
    Ensure-Dir $Destination
    Invoke-Step -Description "copy $Source -> $Destination" -Action {
        Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
    }
}

function Copy-OneFile {
    param([string]$Source, [string]$Destination)
    Ensure-Dir (Split-Path -Parent $Destination)
    Invoke-Step -Description "copy $Source -> $Destination" -Action {
        Copy-Item -Path $Source -Destination $Destination -Force
    }
}

function Assert-Repo {
    $skills = Join-Path $Root "agents\skills"
    $instr  = Join-Path $Root "User\prompts\copilot-instructions.md"
    $agents = Join-Path $Root "AGENTS.md"
    if (-not (Test-Path $skills)) { throw "missing agents\skills (full clone required): $skills" }
    if (-not (Test-Path $instr))  { throw "missing User\prompts\copilot-instructions.md" }
    if (-not (Test-Path $agents)) { throw "missing AGENTS.md (run scripts\sync-instructions.sh first)" }
}

function Sync-Instructions {
    # Native port of scripts\sync-instructions.sh: rebuild the always-on
    # instruction files from shared\coding-style.md. Done in PowerShell so the
    # installer has no bash dependency (Git Bash and WSL disagree on how to
    # interpret Windows paths, which breaks shelling out to the .sh).
    $body = Join-Path $Root "shared\coding-style.md"
    if (-not (Test-Path $body)) { return }
    Invoke-Step -Description "sync instructions from shared\coding-style.md" -Action {
        $bodyBytes = [System.IO.File]::ReadAllBytes($body)
        # Match the body's newline style so regenerated files never churn line endings
        $nl = "`n"
        $firstLf = [Array]::IndexOf($bodyBytes, [byte]10)
        if ($firstLf -gt 0 -and $bodyBytes[$firstLf - 1] -eq 13) { $nl = "`r`n" }
        $header = "---$nl" + "applyTo: `"**`"$nl" + "---$nl$nl"
        $headerBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
        $out = New-Object byte[] ($headerBytes.Length + $bodyBytes.Length)
        [Array]::Copy($headerBytes, 0, $out, 0, $headerBytes.Length)
        [Array]::Copy($bodyBytes, 0, $out, $headerBytes.Length, $bodyBytes.Length)
        [System.IO.File]::WriteAllBytes((Join-Path $Root "User\prompts\copilot-instructions.md"), $out)
        Copy-Item -Path $body -Destination (Join-Path $Root "AGENTS.md") -Force
    }
}

function Install-Skills {
    $dest = Join-Path $UserProfile ".agents\skills"
    Write-Log "→ Skills → $dest"
    $src = Join-Path $Root "agents\skills"
    Copy-Tree -Source $src -Destination $dest
    $count = (Get-ChildItem -Path $src -Directory).Count
    Write-Info "installed $count skill(s)"
}

function Install-VscodeUser {
    param([string]$ProductName, [string]$Label)
    $destUser = Join-Path $AppData (Join-Path $ProductName "User")
    $destPrompts = Join-Path $destUser "prompts"
    Write-Log "→ $Label instructions → $destPrompts"
    Ensure-Dir $destPrompts
    $srcPrompts = Join-Path $Root "User\prompts"
    Invoke-Step -Description "copy prompts into $destPrompts" -Action {
        Copy-Item -Path (Join-Path $srcPrompts "*") -Destination $destPrompts -Recurse -Force
    }
    $legacy = Join-Path $destPrompts "skills"
    if (Test-Path $legacy) {
        Write-Warn "found legacy $legacy (ignored by Copilot); skills go under ~/.agents/skills"
    }
}

function Install-Grok {
    $dest = Join-Path $UserProfile ".grok\AGENTS.md"
    Write-Log "→ Grok always-on → $dest"
    Ensure-Dir (Join-Path $UserProfile ".grok")
    Copy-OneFile -Source (Join-Path $Root "AGENTS.md") -Destination $dest

    if ($GrokSkills) {
        $gskills = Join-Path $UserProfile ".grok\skills"
        Write-Log "→ Grok native skills → $gskills"
        Copy-Tree -Source (Join-Path $Root "agents\skills") -Destination $gskills
    }
}

# --- main -------------------------------------------------------------------

Assert-Repo
Sync-Instructions

$vscodeDetected = [int](Test-VscodeStable)
$insidersDetected = [int](Test-VscodeInsiders)
$grokDetected = [int](Test-Grok)

Write-Log "Repo:     $Root"
Write-Log "Detect:   vscode=$vscodeDetected  insiders=$insidersDetected  grok=$grokDetected"
if ($DryRun) { Write-Log "Mode:     dry-run" }

$wantVscode = $false
$wantInsiders = $false
$wantGrok = $false
$wantSkills = $false

$explicit = $Vscode -or $VscodeInsiders -or $Grok -or $Skills -or $SkillsOnly -or $GrokSkills -or $ForceAll

if ($ForceAll) {
    $wantVscode = $true
    $wantInsiders = $true
    $wantGrok = $true
    $wantSkills = $true
} elseif ($SkillsOnly) {
    $wantSkills = $true
} elseif ($explicit) {
    $wantVscode = [bool]$Vscode
    $wantInsiders = [bool]$VscodeInsiders
    $wantGrok = [bool]$Grok -or [bool]$GrokSkills
    $wantSkills = [bool]$Skills -or [bool]$Grok -or [bool]$Vscode -or [bool]$VscodeInsiders -or [bool]$GrokSkills
    # If user only asked for --grok, still install shared skills (needed for Grok via ~/.agents)
    if ($Grok -or $GrokSkills) { $wantSkills = $true }
    if ($Vscode -or $VscodeInsiders) { $wantSkills = $true }
} else {
    if ($vscodeDetected -or $insidersDetected -or $grokDetected) { $wantSkills = $true }
    if ($vscodeDetected) { $wantVscode = $true }
    if ($insidersDetected) { $wantInsiders = $true }
    if ($grokDetected) { $wantGrok = $true }
}

if (-not ($wantSkills -or $wantVscode -or $wantInsiders -or $wantGrok)) {
    Write-Warn "nothing detected and no targets forced"
    Write-Log "Install a tool (code, code-insiders, grok) or pass -ForceAll / -Vscode / -Grok / -Skills"
    exit 1
}

Write-Log ""
Write-Log "Install plan:"
if ($wantSkills)   { Write-Info "skills → $UserProfile\.agents\skills" }
if ($wantVscode)   { Write-Info "VS Code Stable instructions" }
if ($wantInsiders) { Write-Info "VS Code Insiders instructions" }
if ($wantGrok)     { Write-Info "Grok AGENTS.md → $UserProfile\.grok\AGENTS.md" }
if ($GrokSkills)   { Write-Info "Grok native skills → $UserProfile\.grok\skills" }
Write-Log ""

if ($wantSkills)   { Install-Skills }
if ($wantVscode)   { Install-VscodeUser -ProductName "Code" -Label "VS Code Stable" }
if ($wantInsiders) { Install-VscodeUser -ProductName "Code - Insiders" -Label "VS Code Insiders" }
if ($wantGrok)     { Install-Grok }

Write-Log ""
Write-Log "Done."
if (-not $DryRun) {
    Write-Info "Restart VS Code / start a new Grok session so skills and instructions reload."
}
