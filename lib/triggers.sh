#!/usr/bin/env bash
# triggers.sh — single source of truth for skill-trigger matching.
#
# Sourced by:
#   - hooks-handlers/user-prompt-submit.sh (per-message matching)
#   - hooks-handlers/session-start.sh (priming text)
#
# When adding a skill: update match_skill's case statement here. Also update
# using-team-setup/SKILL.md's catalog (semantic-level — kind/intent, no exact
# phrasings; that level doesn't drift). This file is the authoritative source
# for *syntactic* trigger patterns.

# match_skill: takes lowercased prompt, outputs "skill\tkind" if match, empty
# otherwise. Order matters — most specific first; debug before brainstorm
# (rigid skills outrank flexible ones to avoid mis-fires).
match_skill() {
  local prompt_lower="$1"
  case "$prompt_lower" in
    *"fix"*|*"bug"*|*"failure"*|*"broken"*|*"not working"*|*"error"*|*"crash"*|*"failing test"*)
      printf '%s\t%s\n' "debug" "bug/failure"
      return 0
      ;;
    *"new feature"*|*"add a feature"*|*"build a feature"*|*"add functionality"*|*"adding"*|*"implement"*|*"design"*|*"create a"*)
      printf '%s\t%s\n' "brainstorm" "creative work"
      return 0
      ;;
    *"need to add"*|*"want to add"*|*"need to build"*|*"want to build"*|*"need to create"*|*"want to create"*)
      printf '%s\t%s\n' "brainstorm" "adding/building/creating"
      return 0
      ;;
    *"plan this"*|*"write a plan"*|*"implementation plan"*|*"spec"*)
      printf '%s\t%s\n' "plan" "planning"
      return 0
      ;;
    *"review my"*|*"check my code"*|*"discipline check"*|*"review the"*)
      printf '%s\t%s\n' "discipline-check" "review"
      return 0
      ;;
    *"capture this"*|*"document this"*|*"write up"*|*"capture session"*)
      printf '%s\t%s\n' "doc-capture" "capture"
      return 0
      ;;
    *"adr"*|*"architectural decision"*|*"record decision"*)
      printf '%s\t%s\n' "doc-adr" "ADR"
      return 0
      ;;
    *"explore the"*|*"trace this"*|*"trace the"*|*"map this codebase"*|*"map the codebase"*)
      printf '%s\t%s\n' "explore" "codebase exploration (agent)"
      return 0
      ;;
  esac
  return 1
}

# high_signal_examples: emits the 3 highest-signal trigger→skill mappings as a
# single string for SessionStart priming text. The labels here are SEMANTIC
# summaries of intent (not verbatim patterns), so they stay stable even when
# match_skill's case-branch patterns are edited. ALIGNMENT RULE: if you change
# the semantic focus of debug, brainstorm, or plan in match_skill (e.g., remove
# the "fix" intent entirely), update this string too. Adding a new pattern to
# an existing branch (e.g., "fail" to debug) does NOT require an update here.
high_signal_examples() {
  printf '%s' "'build/add a feature' → brainstorm; 'fix bug/test failure' → debug; 'plan this implementation' → plan"
}
