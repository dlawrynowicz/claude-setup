---
name: team-curate
description: Interactive setup wizard. Audits `~/.claude/` and current project against the team baseline (via doctor checks), proposes changes, asks confirmation per item, applies on approval. Idempotent — safe to re-run. Per scope: global / project shared / project local. Includes optional plugin pruning. Use when setting up a new machine, applying team standards, or reconciling drift.
---

# team-curate

Interactive plan → confirm → apply. Idempotent. Backup-safe.

## Required preparation

1. Run the same checks as `/team-setup:team-doctor` (replicate or invoke; doctor is read-only and has the full check list).
2. Read templates from this plugin's `templates/` directory:
   - `CLAUDE.md.global.template`
   - `CLAUDE.md.project.template`
   - `settings.json.template`
   - `glossary.md.template`
3. Read [`../SHARED.md`](../SHARED.md) for tone.
4. Run `git branch --show-current` for current project context.

## Build the plan

For each gap the audit found, propose a specific change. Group by scope:

### Global (`~/.claude/`)
- Missing `CLAUDE.md` → copy from `templates/CLAUDE.md.global.template`
- `CLAUDE.md` missing a section → append the missing section from template
- `permissions.deny` missing baseline entries → JSON deep-merge (concat + dedupe)
- `permissions.ask` missing baseline entries → same
- `statusLine.command` not at expected path → set to `$HOME/.claude/statusline-launcher.sh`
- `statusline.mjs` / `statusline-launcher.sh` missing → copy from `setup-pack/` (legacy bootstrap location during build phase)
- Plugins outside keep list → offer to set their `enabledPlugins` entries to `false` (this is the prune)

### Project shared (`./`)
- Missing `./CLAUDE.md` → copy from `templates/CLAUDE.md.project.template`, prompt for `{{PROJECT_NAME}}`
- Missing `docs/{decisions,handoffs,features}/` → scaffold empty
- Missing `docs/glossary.md` → copy from `templates/glossary.md.template`, prompt for project name

### Project local (`./.claude/`)
- Missing `settings.local.json` → offer to create empty (untracked; user owns content)

## Show the plan

Present as a numbered list grouped by scope. Use this exact format:

```
PLAN — to apply

[global, ~/.claude/]
  G1. Append "Plugin philosophy" section to CLAUDE.md (currently missing)
  G2. Add 2 missing entries to permissions.ask
  G3. Disable 8 plugins outside keep list: OMC, ralph-loop, claude-md-management, frontend-design, claude-code-setup, code-simplifier, security-guidance, Notion

[project shared, ./]
  P1. Create docs/glossary.md from template (will prompt for project name)
  P2. Scaffold docs/decisions/, docs/handoffs/, docs/features/

[project local, ./.claude/]
  L1. Create empty settings.local.json (untracked)

Apply: [a]ll, [n]one, [s]elect items, [d]etails for each? a/n/s/d:
```

## Confirm per item

Default to per-item confirmation. Per-item input:

| input | meaning |
|---|---|
| `y` / `yes` | apply this item |
| `n` / `no` | skip this item |
| `s` / `skip` | same as no |
| `d` / `details` | show the diff or full content; then ask y/n |
| `q` / `quit` | abort the run; no further changes applied |

If the user enters `a` (all) at the top-level prompt, apply every item without further prompts. Always still backup.

## Apply

For each approved item, perform exactly:

| action | mechanism |
|---|---|
| Create file | write the file. Report path. |
| Append section | read existing file, append the missing section preserving formatting (no reflow). |
| Modify JSON | deep-merge using `jq -s '.[0] * .[1]'` shape. For arrays (`permissions.deny`/`ask`), concat + dedupe. Never blindly overwrite. |
| Disable plugin | set `enabledPlugins["<plugin>@<marketplace>"] = false`. Backup first. |
| Scaffold dirs | `mkdir -p`. No `.gitkeep` unless requested. |

After each apply, report success/failure. Continue with the next.

## Backup safety

Before modifying any existing file:

1. Create `~/.claude/backups/curate-<YYYYMMDD-HHMMSS>/` if not present.
2. Copy the existing file (with directory structure preserved) into the backup dir.
3. Then apply the change.

Never overwrite without a backup. Report the backup directory path at end of run.

## Plugin pruning specifics

When the user approves disabling drop-candidate plugins:

1. Read `~/.claude/settings.json`.
2. Backup it.
3. For each drop candidate, set `.enabledPlugins["<plugin>@<marketplace>"] = false`.
4. Write back the modified JSON with `jq` (preserves shape).
5. Report: "Disabled N plugins. Restart Claude Code to take effect, or run `/plugin reload`."

## After

- Report what was applied vs skipped, with paths.
- Report the backup directory path.
- Suggest re-running `/team-setup:team-doctor` to verify clean state.
- Don't commit anything (the team's `CLAUDE.md` rule: don't commit unless explicitly asked).

## Don't

- Auto-disable plugins without confirmation. Always present drop candidates as a discrete item the user approves.
- Overwrite without backup.
- Apply without confirmation, except when user explicitly said "apply all".
- Modify the *content* of `settings.local.json` — that scope is the user's. Only offer to *create* it empty.
- Scaffold a feature folder unprompted — that's `/team-setup:doc-feature` instead.
