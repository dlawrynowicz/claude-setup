---
name: team-doctor
description: Read-only audit of `~/.claude/` and current project against the team baseline. Reports what's present, what's missing, what differs. Never writes — diagnosis only. Run before `/team-setup:team-curate` to see what would change. Use when the user asks "audit my setup", "what's drifted", or "what's the state of my Claude Code config".
---

# team-doctor

Read-only audit. Reports state; never writes.

## Required preparation

1. Run `git branch --show-current` for current project context (if in a git repo).
2. Read [`../SHARED.md`](../SHARED.md) if present.
3. Read team baseline references: `templates/settings.json.template`, `templates/CLAUDE.md.global.template`.

## Team baseline (for comparison)

**Keep-list plugins:** `superpowers`, `feature-dev`, `context7`, `hookify`, `typescript-lsp`, `learning-output-style`, `team-setup`.

**Drop candidates:** anything NOT in the keep list (informational; doctor doesn't auto-disable).

**Required CLAUDE.md sections:** `## Voice`, `## Plugin philosophy`, `## Discipline`, `## Operations`.

**Required statusLine command:** `$HOME/.claude/statusline-launcher.sh`.

## Checks — global scope (`~/.claude/`)

| check | how |
|---|---|
| settings.json present | `test -f ~/.claude/settings.json` |
| enabledPlugins matches keep list | parse JSON, compare to baseline |
| permissions.deny count | parse JSON `.permissions.deny | length`. Baseline is 24. |
| permissions.ask count | baseline is 6. |
| statusLine.command correct | `$HOME/.claude/statusline-launcher.sh` |
| CLAUDE.md present | `test -f ~/.claude/CLAUDE.md` |
| CLAUDE.md has each required section | `grep -c "^## Voice"`, etc. |
| statusline.mjs present | `test -f ~/.claude/statusline.mjs` |
| statusline-launcher.sh present + executable | `test -x ~/.claude/statusline-launcher.sh` |
| Skills inventory | list `~/.claude/skills/` |
| Memory health | list `~/.claude/projects/*/memory/MEMORY.md` files; flag any > 200 lines (signal of body content, not index) |

## Checks — current project scope (`./`)

| check | how |
|---|---|
| CLAUDE.md present | `test -f ./CLAUDE.md` |
| CLAUDE.md references docs/ | `grep -c "docs/" ./CLAUDE.md` |
| docs/ structure | `test -d docs/{decisions,handoffs,features}` |
| Living docs at root of docs/ | `ls docs/*.md` |
| Hookify rules (if hookify enabled) | `ls .claude/hookify.*.local.md` |
| settings.local.json | `test -f .claude/settings.local.json` |

## Output format

Use this verbatim shape — predictable structure makes drift visible:

```
TEAM-DOCTOR — branch: <current-branch>
                global: ~/.claude/
                project: <pwd>

=== global ===

settings.json:
  ✓ exists
  ⚠ enabledPlugins: 14 enabled, 8 outside team keep list (drop candidates: OMC, ralph-loop, ...)
  ✓ permissions.deny: 24/24 baseline entries
  ⚠ permissions.ask: 4/6 baseline entries (missing: Bash(gh pr create*), Edit(**/.gitignore))
  ✓ statusLine.command: matches expected

CLAUDE.md:
  ✓ exists
  ✓ Voice section
  ✗ Plugin philosophy section missing
  ✓ Discipline section
  ✓ Operations section

statusline:
  ✓ statusline.mjs present
  ✓ statusline-launcher.sh present, executable

skills (~/.claude/skills/):
  ✓ write-ticket
  ✓ write-tech-plan
  ✓ ... (full inventory)
  (info) omc-reference — not in team baseline; OK if intentional

memory:
  ✓ 3 active project memory dirs
  ⚠ ~/.claude/projects/<X>/memory/MEMORY.md is 245 lines (expected <200; suggests body content)

=== project (./) ===

CLAUDE.md:
  ✓ exists
  ✓ references docs/

docs/:
  ✓ docs/decisions/ (3 ADRs)
  ✓ docs/handoffs/
  ✓ docs/features/ (2 features: workshop, team-setup-plugin)

hookify rules:
  ✓ .claude/hookify.funnel-terminology.local.md
  ✓ .claude/hookify.no-git-commit.local.md

settings.local.json:
  ✗ not present (optional; OK to skip)

=== summary ===

Global drift: 3 items
  - CLAUDE.md missing 1 section (Plugin philosophy)
  - permissions.ask missing 2 baseline patterns
  - 8 plugins outside keep list

Project drift: 0 items

Recommendation: run /team-setup:team-curate to apply fixes interactively (per-file confirmation).
```

## When to run

- First time on a new machine.
- After upgrading the plugin.
- Periodically (monthly) to catch drift.
- Before assuming `~/.claude/` matches team baseline.

## Reads only

This skill must not edit any file. If asked to fix something, defer: "Run `/team-setup:team-curate` to apply changes interactively."
