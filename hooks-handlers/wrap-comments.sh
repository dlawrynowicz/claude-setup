#!/usr/bin/env bash
# wrap-comments.sh — PostToolUse hook (SOFT enforcement)
#
# Rewraps comments and docstrings in a file Claude just wrote so every line ends at a clause
# boundary, per skills/SHARED.md "Comments and docstrings". Handles Python, TypeScript and
# JavaScript.
#
# Runs silently and never blocks: it rewrites the file the way `ruff --fix` does. The rule is
# purely mechanical, so applying it beats reporting it.
#
# Only comments next to lines that differ from git HEAD are touched, so editing one function
# never reflows comments elsewhere in the file.
#
# Configurable via $WRAP_COMMENTS_WIDTH (default 99). Set $WRAP_COMMENTS_OFF=1 to disable.
# Reads stdin JSON (PostToolUse event).

set -euo pipefail

[ "${WRAP_COMMENTS_OFF:-0}" = "1" ] && exit 0

input=$(cat)

tool=$(echo "$input" | grep -oE '"tool_name":"[^"]+"' | head -1 | cut -d'"' -f4)
case "$tool" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

if command -v jq >/dev/null 2>&1; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
else
  file_path=$(echo "$input" | grep -oE '"file_path":"[^"]+"' | head -1 | cut -d'"' -f4)
fi

[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0
case "$file_path" in
  *.py|*.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

python3 "${CLAUDE_PLUGIN_ROOT}/lib/wrap_comments.py" \
  "$file_path" --width "${WRAP_COMMENTS_WIDTH:-99}" >/dev/null 2>&1 || true

exit 0
