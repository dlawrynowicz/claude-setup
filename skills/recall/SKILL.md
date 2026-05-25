---
name: recall
description: Search prior Claude Code sessions for context — use when the user asks "what did we discuss about X?", "did we ever decide on Y?", or you need to recover context from a previous session that isn't in current memory.
---

You are searching prior Claude Code sessions.

Search location: `~/.claude/projects/<current-project-id>/*.jsonl`

Steps:
1. Find the current project's session dir: `~/.claude/projects/$(pwd | sed 's|/|-|g')/`
2. Run a grep for the user's search term across all `.jsonl` files in that dir, sorted by modification time (newest first):
   ```
   grep -l "<term>" ~/.claude/projects/<dir>/*.jsonl | head -5
   ```
3. For each matching file, extract the surrounding 3–5 lines of context (use grep -A 2 -B 2).
4. Present results as a matrix:
   | when | session | context snippet |
5. If no matches in current project, ask the user if you should expand to all projects.

Don't dump raw JSONL — extract user messages and assistant text only. Skip tool calls and tool results.

If the user invokes `/recall search-only "<term>"`, just list matching session files without context (faster).
