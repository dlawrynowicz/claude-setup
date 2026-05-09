#!/usr/bin/env bash
# capture-nudge.sh — PostToolUse hook (MEDIUM nudge)
#
# After substantial Write/Edit, emits a systemMessage suggesting
# /team-setup:doc-capture to record the work in docs/. Soft — never blocks.
#
# Threshold: $CAPTURE_NUDGE_THRESHOLD (default 10). Set to 0 to disable.
# Reads stdin JSON (PostToolUse event); writes systemMessage on stdout if triggered.

set -euo pipefail

threshold=${CAPTURE_NUDGE_THRESHOLD:-10}
[ "$threshold" -le 0 ] && exit 0

input=$(cat)

tool=$(echo "$input" | grep -oE '"tool_name":"[^"]+"' | head -1 | cut -d'"' -f4)
case "$tool" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

if command -v jq >/dev/null 2>&1; then
  content=$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
else
  content=$(echo "$input" | grep -oE '"(content|new_string)":"[^"]*"' | head -1 | cut -d'"' -f4)
  file_path=$(echo "$input" | grep -oE '"file_path":"[^"]+"' | head -1 | cut -d'"' -f4)
fi

line_count=$(printf '%s' "$content" | awk 'END{print NR}')

if [ "$line_count" -ge "$threshold" ]; then
  msg="Substantial work to ${file_path:-(file)}: $line_count lines. Consider /team-setup:doc-capture to record in docs/ while context is fresh."
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg m "$msg" '{systemMessage: $m}'
  else
    printf '{"systemMessage":"%s"}\n' "$msg"
  fi
fi

exit 0
