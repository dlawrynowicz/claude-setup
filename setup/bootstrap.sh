#!/usr/bin/env bash
# bootstrap.sh — pre-flight check for team-setup plugin.
# Detects platform, verifies dependencies, prints the launch command.
# Cross-platform: macOS · Linux · Windows/WSL.
# Usage: ./bootstrap.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Platform detection
case "$(uname -s)" in
  Darwin*)  PLATFORM=macos ;;
  Linux*)   PLATFORM=linux ;;   # includes WSL
  *)        PLATFORM=other ;;
esac

echo "team-setup bootstrap"
echo "  Platform: $PLATFORM"
echo "  Plugin:   $PLUGIN_ROOT"
echo ""

errors=0

# bash 4+ check (macOS ships bash 3.2 by default)
# Guard: BASH_VERSION may be unset if script is invoked as `sh bootstrap.sh`
if [ -n "${BASH_VERSION:-}" ]; then
  bash_major="${BASH_VERSION%%.*}"
  if [ "${bash_major:-0}" -lt 4 ]; then
    echo "WARNING: bash $BASH_VERSION detected. Plugin tested on bash 4+."
    if [ "$PLATFORM" = "macos" ]; then
      echo "         Install bash 4+: brew install bash"
    fi
    echo ""
  fi
else
  echo "WARNING: not running under bash. Re-run via 'bash bootstrap.sh' for full check."
  echo ""
fi

# git
if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git not found."
  case "$PLATFORM" in
    macos) echo "         Install: brew install git (or xcode-select --install)" ;;
    linux) echo "         Install: sudo apt-get install git    # Debian/Ubuntu/WSL"
           echo "                  sudo pacman -S git           # Arch"
           echo "                  sudo dnf install git         # Fedora" ;;
    *)     echo "         See https://git-scm.com/downloads" ;;
  esac
  echo ""
  errors=$((errors + 1))
fi

# Claude Code CLI
if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: Claude Code CLI not found in PATH."
  echo "         Install: see https://docs.anthropic.com/claude-code"
  echo "         After install, re-run this script."
  echo ""
  errors=$((errors + 1))
fi

if [ "$errors" -gt 0 ]; then
  echo "Bootstrap blocked on $errors missing dependency(ies)."
  exit 1
fi

# All good — print next-step command
echo "[OK] Dependencies satisfied"
echo ""
echo "Next step — run Claude with the plugin loaded:"
echo ""
echo "  claude --plugin-dir $PLUGIN_ROOT"
echo ""
echo "Then inside Claude, invoke:"
echo ""
echo "  /team-setup:bootstrap-new-machine"
echo ""
echo "That walks you through audit (team-doctor) → apply (team-curate) → verify."
