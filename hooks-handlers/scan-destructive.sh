#!/usr/bin/env bash
# Block bash tool calls that bypass safety mechanisms.
# Operates only on COMMAND FLAGS (syntactic patterns) — not on content.
# This is the only PreToolUse hook in the starter pack: file-based secrets are
# blocked at the deny-list layer in settings.json, which fires before this script.

input=$(cat)

tool=$(echo "$input" | grep -oE '"name":"[^"]+"' | head -1 | cut -d'"' -f4)
if [ "$tool" != "Bash" ]; then
  exit 0
fi

cmd=$(echo "$input" | grep -oE '"command":"[^"]*"' | head -1)

if echo "$cmd" | grep -qE -- '--no-verify|--no-gpg-sign|push --force|push -f |reset --hard|clean -fd[a-z]*'; then
  echo "BLOCKED: command bypasses safety mechanisms. Investigate the underlying issue." >&2
  exit 2
fi

exit 0
