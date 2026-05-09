#!/usr/bin/env bash
# review-required.sh — PostToolUse hook (HARD enforcement)
#
# Blocks the next Claude turn if a single Write or Edit produced >= REVIEW_THRESHOLD
# lines of new content. Per ADR 0002 (layered enforcement, HARD level): substantial
# code changes need review before continuing.
#
# Configurable via $REVIEW_THRESHOLD (default 50). Set to 0 to disable.
# Emits decision:block with a recommendation to run /team-setup:discipline-check.
# Reads stdin JSON (PostToolUse event); writes JSON directive on stdout if blocking.

set -euo pipefail

threshold=${REVIEW_THRESHOLD:-50}
[ "$threshold" -le 0 ] && exit 0

input=$(cat)

tool=$(echo "$input" | grep -oE '"tool_name":"[^"]+"' | head -1 | cut -d'"' -f4)
case "$tool" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

# Get new content + file path. Prefer jq when available; fall back to crude grep.
if command -v jq >/dev/null 2>&1; then
  content=$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // "(unknown)"')
else
  content=$(echo "$input" | grep -oE '"(content|new_string)":"[^"]*"' | head -1 | cut -d'"' -f4)
  file_path=$(echo "$input" | grep -oE '"file_path":"[^"]+"' | head -1 | cut -d'"' -f4)
  file_path=${file_path:-"(unknown)"}
fi

line_count=$(printf '%s' "$content" | awk 'END{print NR}')

if [ "$line_count" -ge "$threshold" ]; then
  cat <<EOF
{
  "decision": "block",
  "reason": "Substantial change to $file_path: $line_count lines. Per ADR 0002 (layered enforcement, HARD level), run /team-setup:discipline-check (or invoke the code-reviewer agent) before continuing. To disable: set REVIEW_THRESHOLD=0. To relax: raise the threshold."
}
EOF
fi

exit 0
