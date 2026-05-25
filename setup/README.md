# team-setup/setup

OS-level integration scripts for things the plugin itself can't provide. Run **once per machine**.

## What's here

| file | purpose |
|------|---------|
| `bootstrap.sh` | pre-flight check — detects platform, verifies deps (bash 4+, git, claude CLI), prints the launch command. Run first on a fresh machine. |
| `install.sh` | installs **statusline** (`statusline.mjs` + launcher) into `~/.claude/`, drops `CLAUDE.md` template if absent, deep-merges `settings.json` (deny/ask rules + statusLine.command). Skips skills/hooks installation — those are auto-discovered by the plugin. |
| `statusline.mjs` | standalone node-based status line — path · git · model · ctx% · daily tokens (daily tokens are macOS-only via Keychain; the rest works cross-platform). Replaces the OMC HUD. |
| `statusline-launcher.sh` | nvm-aware launcher — Claude Code spawns this at every render; sources nvm lazily if node isn't in PATH. |
| `demo-tarballs.sh` | workshop tool — packs before/after snapshots for the workshop demo (not needed for normal use). |

## Order of operations

```bash
# 1. Pre-flight: are deps in place?
bash setup/bootstrap.sh

# 2. OS-level wiring: statusline, settings.json, optional CLAUDE.md
bash setup/install.sh --dry-run    # preview
bash setup/install.sh              # apply

# 3. Load the plugin
claude --plugin-dir <path-to-team-setup>

# 4. Inside Claude: guided onboarding (optional)
/team-setup:bootstrap-new-machine
```

`install.sh` is **idempotent** — re-run anytime. Backs up existing files to `~/.claude/backups/curation-pack-<timestamp>/`.

## Cross-platform

| platform | install.sh | statusline rate-limit |
|---|---|---|
| macOS | ✓ | ✓ (reads Keychain) |
| Linux | ✓ | gracefully degrades — statusbar shows path/git/model/ctx without daily-token totals |
| Windows/WSL | ✓ | same as Linux |

`install.sh` checks for `jq` (**required** — hard-fails with install hints) and `node` (**recommended** — warns but continues; launcher retries nvm at every render).

## What `install.sh` does NOT do

- Install skills, agents, or hooks — the plugin auto-discovers all of these from the plugin directory via `claude --plugin-dir`.
- Modify project-local files — only touches `~/.claude/`. For project-scoped customization, use `/team-setup:team-curate` inside Claude.

## Customize

| want to change | edit |
|----------------|------|
| Add deny patterns | `../templates/settings.json.template` → `permissions.deny` |
| Adjust statusline format | `statusline.mjs` (edit `format()` near bottom; ANSI colors near top) |
| Tweak universal rules | `../templates/CLAUDE.md.global.template` |

## Rollback

```bash
ls ~/.claude/backups/curation-pack-*                                # find backup dir
cp -r ~/.claude/backups/curation-pack-<timestamp>/* ~/.claude/      # restore
```

## Verify

After install + plugin load, in a fresh Claude Code session:

```
/context                                          # baseline should reflect plugin load
/plugin                                           # should list team-setup
cat ~/.claude/settings.json | jq '.permissions.deny | length'   # should include baseline deny rules
```
