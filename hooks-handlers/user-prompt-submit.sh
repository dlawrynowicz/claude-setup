#!/usr/bin/env bash
# user-prompt-submit.sh — UserPromptSubmit hook
#
# Fires on every user message. Detects skill-trigger keywords and injects a
# per-message reminder telling Claude to check the matching team-setup skill
# BEFORE responding.
#
# This is the per-message bias mechanism. SessionStart priming alone gets buried
# by intervening context; UserPromptSubmit fires immediately before Claude's
# response, where attention is highest.
#
# Reads stdin JSON (UserPromptSubmit event with .prompt field).
# Writes hookSpecificOutput with additionalContext IF a trigger matches.
# Silent on no-match (no overhead for unrelated messages).

set -euo pipefail

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  prompt=$(echo "$input" | jq -r '.prompt // empty')
else
  prompt=$(echo "$input" | grep -oE '"prompt":"[^"]*"' | head -1 | cut -d'"' -f4)
fi

[ -z "$prompt" ] && exit 0

# Lowercase for matching (with ASCII fallback if locale issues)
prompt_lower=$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]' 2>/dev/null || printf '%s' "$prompt")

# Match via canonical lib/triggers.sh (single source of truth — see DRY rationale
# in plan v23). Patterns and ordering live there; this hook just consumes.
# Guarded source: silent skip if CLAUDE_PLUGIN_ROOT or lib unavailable, so a
# misconfigured hook can't crash the user prompt.
[ -f "${CLAUDE_PLUGIN_ROOT:-}/lib/triggers.sh" ] || exit 0
source "${CLAUDE_PLUGIN_ROOT}/lib/triggers.sh"

matched_skill=""
matched_kind=""
if result=$(match_skill "$prompt_lower"); then
  matched_skill=$(printf '%s' "$result" | cut -f1)
  matched_kind=$(printf '%s' "$result" | cut -f2)
fi

if [ -n "$matched_skill" ]; then
  msg="REMINDER: user request matches team-setup:${matched_skill} trigger (${matched_kind}). Per using-team-setup, you MUST check this skill BEFORE responding. Invoke via the Skill tool. If you've already determined a different team-setup skill is more appropriate, invoke that one instead — but DO invoke a skill before ad-hoc bash/grep exploration. The 1% rule applies: brainstorm/debug/plan/etc. are designed for these triggers; bash is the fallback when no skill matches."

  if command -v jq >/dev/null 2>&1; then
    jq -n --arg ctx "$msg" '{
      hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        additionalContext: $ctx
      }
    }'
  else
    printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$msg"
  fi
fi

exit 0
