#!/usr/bin/env bash
# code-style-reminder.sh — PostToolUse hook (SOFT enforcement)
#
# Puts the house comment style in front of Claude the first time it writes code in a session.
#
# The rules already live in skills/SHARED.md and the per-language clean-code skills, but nothing
# loads those unless a prompt keyword happens to match a skill trigger. Writing code is not a
# trigger, so the rules were being missed for whole sessions and only caught later in review.
# This fires on the write itself.
#
# Claude edits files through Bash as often as through Write/Edit (heredocs, sed -i, small python
# scripts), so this matches Bash too. A session that edited 15 files through Bash used to get no
# reminder at all.
#
# Once per session per language family, so it does not become noise. Set $CODE_STYLE_REMINDER_OFF=1
# to disable. Reads stdin JSON (PostToolUse event); writes reminder text on stdout.

set -euo pipefail

[ "${CODE_STYLE_REMINDER_OFF:-0}" = "1" ] && exit 0

input=$(cat)

tool=$(echo "$input" | grep -oE '"tool_name":"[^"]+"' | head -1 | cut -d'"' -f4)
case "$tool" in
  Write|Edit|Bash) ;;
  *) exit 0 ;;
esac

if command -v jq >/dev/null 2>&1; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
  command_text=$(echo "$input" | jq -r '.tool_input.command // empty')
  session=$(echo "$input" | jq -r '.session_id // empty')
else
  file_path=$(echo "$input" | grep -oE '"file_path":"[^"]+"' | head -1 | cut -d'"' -f4)
  command_text=$(echo "$input" | grep -oE '"command":"[^"]*"' | head -1 | cut -d'"' -f4)
  session=$(echo "$input" | grep -oE '"session_id":"[^"]+"' | head -1 | cut -d'"' -f4)
fi

# A Bash call only counts when the command writes: a redirect, tee, an in-place sed, or a
# python/node snippet opening a file for writing. Reading a source file is not a write.
if [ -z "$file_path" ] && [ -n "$command_text" ]; then
  case "$command_text" in
    *">"*|*"tee "*|*"sed -i"*|*".write("*|*"open("*|*"writeFileSync"*) ;;
    *) exit 0 ;;
  esac
  file_path=$(printf '%s' "$command_text" \
    | grep -oE "[A-Za-z0-9_./-]+\.(py|ts|tsx|js|jsx)" \
    | head -1 || true)
fi

[ -z "$file_path" ] && exit 0
case "$file_path" in
  *.py)                      family="python"; skill="python-clean-code" ;;
  *.ts|*.tsx|*.js|*.jsx)     family="frontend"; skill="archer-clean-code" ;;
  *) exit 0 ;;
esac

marker="${TMPDIR:-/tmp}/claude-style-reminder-${session:-$PPID}-${family}"
[ -f "$marker" ] && exit 0
touch "$marker"

cat <<REMINDER
House comment style applies to this file (skills/SHARED.md, "House style"; also the $skill skill):
- Branching on a domain case? Lead-in line, then one bullet per case, naming the case in domain
  words rather than the isinstance/type check. Not a prose paragraph.
- Say "we", present tense. Not "the system", not passive.
- Human word first, model name in "(i.e. ...)": "a new roommate (i.e. applicant role)".
- Quote a setting by its on-screen label, not its field name.
- Say when you don't know. An honest gap beats an invented rationale.
- Delete any comment that restates the symbol above it.
- No comment that argues for the design ("so X doesn't happen"). The test pins it instead.
- Editing a type, list or signature? Re-read the comment above it - a stale count or name there
  is the most common thing review catches.
REMINDER

exit 0
