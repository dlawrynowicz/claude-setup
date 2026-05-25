#!/usr/bin/env bash
# install.sh — installs OS-level integrations that the plugin itself can't provide.
# What this installs:
#   1. Standalone statusline (statusline.mjs + launcher) into ~/.claude/
#   2. Global ~/.claude/CLAUDE.md template (only if absent)
#   3. Settings.json deep merge for deny/ask rules + statusLine.command
#
# What this does NOT install:
#   - Skills, hooks, agents — those are auto-discovered by the plugin via
#     `claude --plugin-dir <path-to-team-setup>`. No file copying needed.
#
# Cross-platform: macOS · Linux · Windows/WSL.
# Rate-limit fetch in statusline is macOS-only (reads Keychain); other
# platforms get a statusbar without daily-token totals.
#
# Usage: ./install.sh [--dry-run]

set -euo pipefail

DRY_RUN=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true

# Platform detection
case "$(uname -s)" in
  Darwin*) PLATFORM=macos ;;
  Linux*)  PLATFORM=linux ;;        # includes WSL
  *)       PLATFORM=other ;;
esac

# Dependency check: jq (required for settings.json deep merge)
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required. Install with:"
  case "$PLATFORM" in
    macos) echo "  brew install jq" ;;
    linux) echo "  sudo apt-get install jq    # Debian/Ubuntu/WSL"
           echo "  sudo pacman -S jq          # Arch"
           echo "  sudo dnf install jq        # Fedora" ;;
    *)     echo "  See https://jqlang.org/download/ for your platform" ;;
  esac
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"   # team-setup/
TARGET="$HOME/.claude"
BACKUP_DIR="$TARGET/backups/curation-pack-$(date +%Y%m%d-%H%M%S)"

run() {
  if $DRY_RUN; then
    echo "DRY-RUN: $*"
  else
    "$@"
  fi
}

echo "Installing curation pack from $SCRIPT_DIR to $TARGET"
echo "Plugin root: $PLUGIN_ROOT"
echo "Backups: $BACKUP_DIR"
$DRY_RUN && echo "(dry run — no changes)"

run mkdir -p "$BACKUP_DIR"

# 1. Statusline (node-based, standalone) + nvm-aware launcher
if ! command -v node >/dev/null 2>&1; then
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    # shellcheck source=/dev/null
    \. "$HOME/.nvm/nvm.sh" --no-use 2>/dev/null
    nvm use default >/dev/null 2>&1 || nvm use node >/dev/null 2>&1 || true
  fi
fi
if ! command -v node >/dev/null 2>&1; then
  echo "WARNING: node not found in PATH or via nvm."
  case "$PLATFORM" in
    macos) echo "         Install: brew install node — or nvm install --lts" ;;
    linux) echo "         Install: nvm install --lts — or sudo apt-get install nodejs" ;;
    *)     echo "         Install Node.js via your platform's package manager." ;;
  esac
  echo "         Continuing — the launcher will retry sourcing nvm at every render."
fi
for f in statusline.mjs statusline-launcher.sh; do
  if [ -f "$TARGET/$f" ]; then
    run cp "$TARGET/$f" "$BACKUP_DIR/"
  fi
  run cp "$SCRIPT_DIR/$f" "$TARGET/"
done
run chmod +x "$TARGET/statusline-launcher.sh"

# 2. CLAUDE.md (only if absent — never overwrite user content)
if [ -f "$TARGET/CLAUDE.md" ]; then
  echo "Note: existing ~/.claude/CLAUDE.md found — left untouched."
  echo "      Template at $PLUGIN_ROOT/templates/CLAUDE.md.global.template — review and merge manually if you want our defaults."
else
  run cp "$PLUGIN_ROOT/templates/CLAUDE.md.global.template" "$TARGET/CLAUDE.md"
fi

# 3. settings.json (deep merge via jq)
if [ -f "$TARGET/settings.json" ]; then
  run cp "$TARGET/settings.json" "$BACKUP_DIR/"
  if $DRY_RUN; then
    echo "DRY-RUN: would deep-merge settings.json with $PLUGIN_ROOT/templates/settings.json.template"
  else
    tmp=$(mktemp)
    jq -s '
      .[0] as $existing
      | .[1] as $new
      | $existing
        * { permissions: ($existing.permissions // {}) * { deny: (((($existing.permissions // {}).deny // []) + ($new.permissions.deny // [])) | unique), ask: (((($existing.permissions // {}).ask // []) + ($new.permissions.ask // [])) | unique) } }
        * { statusLine: $new.statusLine }
    ' "$TARGET/settings.json" "$PLUGIN_ROOT/templates/settings.json.template" > "$tmp"
    mv "$tmp" "$TARGET/settings.json"
  fi
else
  if $DRY_RUN; then
    echo "DRY-RUN: would copy template to $TARGET/settings.json (with _comment stripped)"
  else
    jq 'del(._comment)' "$PLUGIN_ROOT/templates/settings.json.template" > "$TARGET/settings.json"
  fi
fi

echo ""
echo "Done. Backup at $BACKUP_DIR"
if [ "$PLATFORM" != "macos" ]; then
  echo "Note: statusline rate-limit fetch is macOS-only (Keychain). On $PLATFORM"
  echo "      the statusbar shows path/git/model/ctx without daily-token totals."
fi
echo ""
echo "Next — load the plugin:"
echo "  claude --plugin-dir $PLUGIN_ROOT"
echo ""
echo "Then inside Claude: invoke '/team-setup:bootstrap-new-machine' for the guided wizard,"
echo "or just start working — the skills auto-fire on trigger keywords."
