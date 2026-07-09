#!/usr/bin/env bash
# Install this agent-config profile for GitHub Copilot (VS Code / Insiders)
# and/or Grok Build on Linux (and other Unix-like systems).
#
# Usage:
#   ./scripts/install.sh                 # auto-detect and install what is present
#   ./scripts/install.sh --dry-run       # print actions only
#   ./scripts/install.sh --force-all     # install every target even if not detected
#   ./scripts/install.sh --skills-only   # only ~/.agents/skills
#   ./scripts/install.sh --vscode --vscode-insiders --grok
#   ./scripts/install.sh --grok-skills   # also copy skills to ~/.grok/skills
#   ./scripts/install.sh --help
#
# Install map:
#   agents/skills/*  →  ~/.agents/skills/     (Copilot + Grok personal skills)
#   User/prompts/*   →  VS Code User/prompts/ (Stable and/or Insiders)
#   AGENTS.md        →  ~/.grok/AGENTS.md     (Grok always-on)
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

DRY_RUN=0
FORCE_ALL=0
SKILLS_ONLY=0
WANT_VSCODE=0
WANT_INSIDERS=0
WANT_GROK=0
WANT_SKILLS=0
GROK_NATIVE_SKILLS=0
EXPLICIT=0

log()  { printf '%s\n' "$*"; }
info() { printf '  %s\n' "$*"; }
warn() { printf 'warn: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --force-all) FORCE_ALL=1 ;;
    --skills-only) SKILLS_ONLY=1; WANT_SKILLS=1; EXPLICIT=1 ;;
    --vscode) WANT_VSCODE=1; EXPLICIT=1 ;;
    --vscode-insiders|--insiders) WANT_INSIDERS=1; EXPLICIT=1 ;;
    --grok) WANT_GROK=1; EXPLICIT=1 ;;
    --skills) WANT_SKILLS=1; EXPLICIT=1 ;;
    --grok-skills) GROK_NATIVE_SKILLS=1; WANT_GROK=1; EXPLICIT=1 ;;
    -h|--help) usage ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

# --- detect tools -----------------------------------------------------------

have_cmd() { command -v "$1" >/dev/null 2>&1; }

detect_vscode_stable() {
  have_cmd code && return 0
  [[ -d "$CFG_HOME/Code/User" ]] && return 0
  [[ -d "$CFG_HOME/Code" ]] && return 0
  return 1
}

detect_vscode_insiders() {
  have_cmd code-insiders && return 0
  [[ -d "$CFG_HOME/Code - Insiders/User" ]] && return 0
  [[ -d "$CFG_HOME/Code - Insiders" ]] && return 0
  return 1
}

detect_grok() {
  have_cmd grok && return 0
  # Grok Build binary names seen in the wild
  have_cmd grok-build && return 0
  [[ -d "$HOME/.grok" ]] && return 0
  [[ -f "$HOME/.grok/config.toml" ]] && return 0
  return 1
}

# --- helpers ----------------------------------------------------------------

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "dry-run: $*"
    return 0
  fi
  "$@"
}

ensure_dir() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "dry-run: mkdir -p $1"
    return 0
  fi
  mkdir -p "$1"
}

# Copy directory contents (src/.) into dest/, creating dest.
# Does NOT delete extra files in dest (other personal skills stay put).
copy_tree() {
  local src="$1" dest="$2"
  ensure_dir "$dest"
  if have_cmd rsync; then
    run rsync -a "${src}/" "${dest}/"
  else
    if [[ "$DRY_RUN" -eq 1 ]]; then
      info "dry-run: cp -a ${src}/. ${dest}/"
    else
      cp -a "${src}/." "${dest}/"
    fi
  fi
}

copy_file() {
  local src="$1" dest="$2"
  ensure_dir "$(dirname "$dest")"
  run cp -a "$src" "$dest"
}

require_repo() {
  [[ -d "$ROOT/agents/skills" ]] || die "missing $ROOT/agents/skills (run from a full clone)"
  [[ -f "$ROOT/User/prompts/copilot-instructions.md" ]] || die "missing User/prompts/copilot-instructions.md"
  [[ -f "$ROOT/AGENTS.md" ]] || die "missing AGENTS.md (run scripts/sync-instructions.sh)"
}

sync_instructions() {
  if [[ -x "$ROOT/scripts/sync-instructions.sh" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      info "dry-run: sync-instructions.sh"
    else
      "$ROOT/scripts/sync-instructions.sh" >/dev/null
    fi
  fi
}

install_skills() {
  local dest="$HOME/.agents/skills"
  log "→ Skills → $dest"
  copy_tree "$ROOT/agents/skills" "$dest"
  info "installed $(find "$ROOT/agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') skill(s)"
}

install_vscode_user() {
  local product="$1"   # Code | Code - Insiders
  local label="$2"
  local dest="$CFG_HOME/$product/User"
  log "→ $label instructions → $dest/prompts/"
  ensure_dir "$dest"
  # Only prompts we ship (do not wipe entire User profile)
  ensure_dir "$dest/prompts"
  if have_cmd rsync; then
    run rsync -a "$ROOT/User/prompts/" "$dest/prompts/"
  else
    if [[ "$DRY_RUN" -eq 1 ]]; then
      info "dry-run: cp -a $ROOT/User/prompts/. $dest/prompts/"
    else
      cp -a "$ROOT/User/prompts/." "$dest/prompts/"
    fi
  fi
  # Never leave a stale User/prompts/skills if an old install put skills there
  if [[ -d "$dest/prompts/skills" ]]; then
    warn "found legacy $dest/prompts/skills (ignored by Copilot); leaving in place"
    warn "skills are installed under ~/.agents/skills instead"
  fi
}

install_grok() {
  local dest="$HOME/.grok/AGENTS.md"
  log "→ Grok always-on → $dest"
  ensure_dir "$HOME/.grok"
  copy_file "$ROOT/AGENTS.md" "$dest"

  if [[ "$GROK_NATIVE_SKILLS" -eq 1 ]]; then
    log "→ Grok native skills → $HOME/.grok/skills"
    copy_tree "$ROOT/agents/skills" "$HOME/.grok/skills"
  fi
}

# --- plan -------------------------------------------------------------------

require_repo
sync_instructions

VSCODE_DETECTED=0
INSIDERS_DETECTED=0
GROK_DETECTED=0

detect_vscode_stable && VSCODE_DETECTED=1
detect_vscode_insiders && INSIDERS_DETECTED=1
detect_grok && GROK_DETECTED=1

log "Repo:     $ROOT"
log "Detect:   vscode=$VSCODE_DETECTED  insiders=$INSIDERS_DETECTED  grok=$GROK_DETECTED"
[[ "$DRY_RUN" -eq 1 ]] && log "Mode:     dry-run"

if [[ "$FORCE_ALL" -eq 1 ]]; then
  WANT_VSCODE=1
  WANT_INSIDERS=1
  WANT_GROK=1
  WANT_SKILLS=1
  EXPLICIT=1
fi

if [[ "$EXPLICIT" -eq 0 ]]; then
  # Auto: skills if any consumer exists; instructions per detected tool
  if [[ "$VSCODE_DETECTED" -eq 1 || "$INSIDERS_DETECTED" -eq 1 || "$GROK_DETECTED" -eq 1 ]]; then
    WANT_SKILLS=1
  fi
  [[ "$VSCODE_DETECTED" -eq 1 ]] && WANT_VSCODE=1
  [[ "$INSIDERS_DETECTED" -eq 1 ]] && WANT_INSIDERS=1
  [[ "$GROK_DETECTED" -eq 1 ]] && WANT_GROK=1
fi

if [[ "$SKILLS_ONLY" -eq 1 ]]; then
  WANT_VSCODE=0
  WANT_INSIDERS=0
  WANT_GROK=0
  WANT_SKILLS=1
fi

if [[ "$WANT_SKILLS" -eq 0 && "$WANT_VSCODE" -eq 0 && "$WANT_INSIDERS" -eq 0 && "$WANT_GROK" -eq 0 ]]; then
  warn "nothing detected and no targets forced"
  log "Install a tool (code, code-insiders, grok) or pass --force-all / --vscode / --grok / --skills"
  exit 1
fi

log ""
log "Install plan:"
[[ "$WANT_SKILLS" -eq 1 ]] && info "skills → ~/.agents/skills"
[[ "$WANT_VSCODE" -eq 1 ]] && info "VS Code Stable instructions"
[[ "$WANT_INSIDERS" -eq 1 ]] && info "VS Code Insiders instructions"
[[ "$WANT_GROK" -eq 1 ]] && info "Grok AGENTS.md → ~/.grok/AGENTS.md"
[[ "$GROK_NATIVE_SKILLS" -eq 1 ]] && info "Grok native skills → ~/.grok/skills"
log ""

# --- execute ----------------------------------------------------------------

[[ "$WANT_SKILLS" -eq 1 ]] && install_skills
[[ "$WANT_VSCODE" -eq 1 ]] && install_vscode_user "Code" "VS Code Stable"
[[ "$WANT_INSIDERS" -eq 1 ]] && install_vscode_user "Code - Insiders" "VS Code Insiders"
[[ "$WANT_GROK" -eq 1 ]] && install_grok

log ""
log "Done."
if [[ "$DRY_RUN" -eq 0 ]]; then
  info "Restart VS Code / start a new Grok session so skills and instructions reload."
fi
