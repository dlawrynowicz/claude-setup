#!/usr/bin/env bash
# session-start.sh — SessionStart hook
#
# Two purposes:
#   1. ALWAYS inject `using-team-setup` priming so Claude actively checks skills
#      before defaulting to bash/grep exploration. This is the load-bearing piece —
#      skill descriptions in the registry aren't enough; explicit session-start
#      priming is what creates the invocation bias (mirrors how learning-output-style
#      works for output style).
#   2. Conditionally surface doc-audit drift signals when stale files are present.
#
# Reads stdin JSON (SessionStart event with cwd); writes hookSpecificOutput JSON.

set -euo pipefail

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  cwd=$(echo "$input" | jq -r '.cwd // empty')
else
  cwd=$(echo "$input" | grep -oE '"cwd":"[^"]+"' | head -1 | cut -d'"' -f4)
fi

# 1. Always-injected priming — creates the skill-check bias
# Examples sourced from canonical lib/triggers.sh (single source of truth)
# Guarded source: silent skip if unavailable so a misconfigured hook doesn't
# crash the session-start event.
[ -f "${CLAUDE_PLUGIN_ROOT:-}/lib/triggers.sh" ] || exit 0
source "${CLAUDE_PLUGIN_ROOT}/lib/triggers.sh"
examples=$(high_signal_examples)
priming="team-setup plugin loaded. CRITICAL: before responding to feature-scale requests, check whether a team-setup skill applies — invoke 'using-team-setup' to see the full catalog. The 1% rule applies: if any chance a skill matches the work, invoke it via the Skill tool BEFORE ad-hoc exploration. Highest-signal triggers: ${examples}. Don't substitute bash/grep for skills designed for the task; ad-hoc exploration remains correct for show-me-the-codebase requests where no skill matches."

# 2. Optional doc-audit — wrapped defensively so any failure can't kill priming
audit_msg=""
{
  if [ -n "$cwd" ] && [ -d "$cwd/docs" ]; then
    stale_threshold=${STALE_DAYS:-90}
    now=$(date +%s)
    stale_count=0

    while IFS= read -r f; do
      if mtime=$(stat -f %m "$f" 2>/dev/null) || mtime=$(stat -c %Y "$f" 2>/dev/null); then
        age_days=$(( (now - mtime) / 86400 ))
        if [ "$age_days" -gt "$stale_threshold" ]; then
          stale_count=$((stale_count + 1))
        fi
      fi
    done < <(find "$cwd/docs" -type f -name "*.md" 2>/dev/null || true)

    if [ "$stale_count" -gt 0 ]; then
      audit_msg=" Also: doc-audit found $stale_count stale doc(s) (>$stale_threshold days untouched). Run team-setup:doc-audit for the full drift report."
    fi
  fi
} || audit_msg=""

msg="${priming}${audit_msg}"

if command -v jq >/dev/null 2>&1; then
  jq -n --arg ctx "$msg" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: $ctx
    }
  }'
else
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$msg"
fi

exit 0
