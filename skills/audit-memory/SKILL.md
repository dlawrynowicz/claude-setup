---
name: audit-memory
description: Audit `MEMORY.md` and memory files in `~/.claude/projects/*/memory/` for bloat, duplicates, and stale entries. Read-only — surfaces a matrix of findings; never modifies files. Run quarterly or whenever `/context` at session start surprises you. Companion to `/team-setup:team-doctor`.
---

# audit-memory

Read-only audit of the auto-memory system. Surfaces findings as a matrix; never modifies files.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone (terse, "we" voice, matrix format).
2. Identify the project's memory dir: `~/.claude/projects/<project-id>/memory/`.

## Checks

| # | check | how |
|---|---|---|
| 1 | **Size check** | `wc -l ~/.claude/projects/<id>/memory/*.md` sorted by line count. Flag any single file > 50 lines (likely has body content that belongs in `docs/`). |
| 2 | **MEMORY.md hygiene** | Read `MEMORY.md`. Flag lines > 150 chars (probably body content hiding in an index entry). Flag total length > 30 lines. |
| 3 | **Stale check** | `find ~/.claude/projects/<id>/memory -mtime +60 -name "*.md"` — files not touched in 60+ days. |
| 4 | **Duplicate check** | For each memory file title, grep `docs/` for the same topic. If found, flag as potential duplicate. |
| 5 | **Active-features check** | If `project_active_features.md` exists, cross-check listed branches against `git branch -a`. Branches no longer present likely mean stale memory. |

## Output

```
AUDIT-MEMORY — ~/.claude/projects/<id>/memory/

| file                | size | last modified | finding              | action       |
|---------------------|------|---------------|----------------------|--------------|
| MEMORY.md           |  18  | 2026-04-22    | clean                | keep         |
| feedback_voice.md   |  72  | 2026-05-06    | over 50 lines        | move-to-docs |
| project_old.md      |  12  | 2026-01-10    | stale (>60 days)     | delete       |

Summary: 3 entries flagged for action.
```

Where `action` is one of: `keep`, `collapse`, `delete`, `move-to-docs`.

## Don't

- Don't modify files. The user reviews the matrix and decides.
- Don't audit other users' memory dirs (only the current `cwd` project's).
- Don't conflate `MEMORY.md` (index) with memory body files (content). They have different size budgets.
