# team-setup

Claude Code plugin bundling our team's standard setup: voice rules, layered enforcement, doc workflow, writing skills, and an interactive audit-and-apply flow.

## What it gives you

- **Setup wizard** — `/team-setup:team-doctor` audits your `~/.claude/`; `/team-setup:team-curate` proposes and applies changes per scope (global / project shared / project local).
- **Doc workflow** — branch-aware capture into a feature-grouped layout (`docs/features/<feature>/`); ADR scaffolding with auto-numbering; drift detection.
- **Writing skills** — team-voice ticket, tech plan, product doc, PR description, E2E test plan, QA reply, doc update.
- **Layered enforcement** — hard rules via `settings.json` deny + PreToolUse hooks; medium via PostToolUse nudges + SessionStart silent audits; soft via CLAUDE.md principles.

## Install

### Local dev (current)

Clone the repo and point Claude Code at the plugin directory:

```bash
git clone <repo-url> team-setup
claude --plugin-dir team-setup
```

The plugin auto-discovers skills, hooks, and agents from this directory. Nothing to register manually.

### Platform requirements

- **macOS / Linux** — runs natively.
- **Windows** — runs under **WSL** (the hooks are bash scripts; native cmd/PowerShell is not supported). Git Bash works for most cases too but WSL is the tested path.

`.gitattributes` enforces LF on `*.sh`, so cloning on Windows won't break line endings.

### Custom marketplace (planned, post-stabilization)

```bash
/plugin marketplace add your-org/claude-plugins
/plugin install team-setup@your-org
```

## Use

### First-time setup on a new machine

```
/team-setup:team-doctor      # read-only audit of your ~/.claude/
/team-setup:team-curate      # interactive: propose plan → confirm per file → apply
```

Both are idempotent. Re-run anytime — the doctor reports drift, the curate flow asks before changing anything. Per scope, you choose: install globally, scope to current project, or local override.

### Daily doc workflow

```
/team-setup:doc-feature <name>     # scaffold docs/features/<name>/ with starter design.md, plan.md, notes.md
/team-setup:doc-capture            # capture current session's work to the right doc location (auto-detects type)
/team-setup:doc-adr                # scaffold next-numbered ADR (system-wide or feature-scoped)
/team-setup:doc-audit              # drift report — branch-aware, distinguishes branch view from main
```

### Writing in team voice

```
/team-setup:write-ticket
/team-setup:write-tech-plan
/team-setup:write-product-doc
/team-setup:write-pr-description
/team-setup:write-e2e-test-plan
/team-setup:reply-to-qa
/team-setup:update-docs
```

Each preserves the team's voice (terse, "we" form, conversational, matrix-format for complex content). Project-specific glossaries are honored automatically.

### Discipline + memory

```
/team-setup:audit-memory       # consolidate ~/.claude/projects/*/memory/ — flag stale, deduplicate
/team-setup:discipline-check   # TDD/DRY/SOLID checklist for current code
/team-setup:glossary-check     # warn on terminology drift in current files
```

## Customization

Personal overrides take precedence over plugin defaults. To override any skill, drop a same-named skill into `~/.claude/skills/<skill-name>/`. Claude Code resolves personal → plugin in that order, so your customization wins.

For project-specific tuning, put files in `<repo>/.claude/`. The plugin's `team-curate` skill scaffolds these on demand.

## Architecture

The plugin organizes content by enforcement level (hard / medium / soft) and by scope (global default / project override). Three principles, documented as ADRs in the parent project:

- **Build before install** — `../docs/decisions/0001-build-before-install.md`
- **Layered enforcement** — `../docs/decisions/0002-layered-enforcement.md`
- **Feature-grouped docs** — `../docs/decisions/0003-feature-grouped-docs.md`

Full design rationale: `../docs/features/team-setup-plugin/design.md`.

## Status

Build in progress. See `../docs/features/team-setup-plugin/plan.md` for the 8-step sequence and current state.
