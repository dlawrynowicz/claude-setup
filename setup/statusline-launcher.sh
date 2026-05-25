#!/usr/bin/env bash
# Statusline launcher — sources nvm if needed, then runs the node statusline.
# Claude Code spawns this at every render. Cheap path: node already in PATH → exec.
# Slow path: not in PATH but nvm is installed → source nvm lazily, then exec.

if ! command -v node >/dev/null 2>&1; then
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    # shellcheck source=/dev/null
    \. "$HOME/.nvm/nvm.sh" --no-use 2>/dev/null
    nvm use default >/dev/null 2>&1 || nvm use node >/dev/null 2>&1 || true
  fi
fi

exec node "$HOME/.claude/statusline.mjs" "$@"
