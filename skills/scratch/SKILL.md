---
name: scratch
description: Mid-session scratch notes — use to capture working thoughts, intermediate findings, or to-dos that aren't worth a memory file but are too important to lose between turns. Invoke when the user says "note that", "save this", or you're about to lose state across a long workflow.
---

You are writing a mid-session scratch note.

Append the note to `.claude-learnings/scratch.md` in the current project root (create the file if it doesn't exist). Format:

```
## YYYY-MM-DD HH:MM — <one-line summary>

<note body — 1–5 lines>
```

Rules:
- Use the current timestamp (run `date +"%Y-%m-%d %H:%M"`).
- Keep the body short. If it's longer than 5 lines, it belongs in a real doc.
- After appending, confirm in one line: "Saved to scratch (line N)."

When the user invokes `/scratch read`, read the entire `.claude-learnings/scratch.md` and present the last 10 entries.

When the user invokes `/scratch clear`, archive the current file to `.claude-learnings/scratch.archive.<timestamp>.md` and start fresh.
