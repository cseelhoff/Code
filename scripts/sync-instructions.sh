#!/usr/bin/env bash
# Rebuild always-on instruction files from shared/coding-style.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BODY="$ROOT/shared/coding-style.md"
test -f "$BODY"

{
  printf '%s\n' '---' 'applyTo: "**"' '---' ''
  cat "$BODY"
} > "$ROOT/User/prompts/copilot-instructions.md"

cp "$BODY" "$ROOT/AGENTS.md"
echo "Synced shared/coding-style.md → User/prompts/copilot-instructions.md + AGENTS.md"
