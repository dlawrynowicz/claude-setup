# team-setup

Claude Code plugin that turns curated team standards into **auto-firing skills, hooks, and agents** — so the team's discipline (TDD, DRY, SOLID, layered enforcement) shows up without anyone having to remember to invoke it.

## Quick start

```bash
git clone <this-repo-url> team-setup
bash team-setup/setup/bootstrap.sh    # pre-flight: deps check, prints next-step command
claude --plugin-dir team-setup
```

Inside Claude, run the guided onboarding wizard:

```
/team-setup:bootstrap-new-machine    # explicit-invoke; walks audit → apply → verify
```

Or skip the wizard and smoke-test directly — type *"let's add a feature"*, `team-setup:brainstorm` should auto-fire. If it doesn't, see [Verify](#verify-it-works) and [Troubleshooting](#troubleshooting).

## What's inside

| | inventory |
|---|---|
| **25 skills** | `brainstorm`, `plan`, `execute`, `debug`, `tdd`, `discipline-check`, `using-team-setup` (meta), `bootstrap-new-machine` (guided onboarding wizard), `team-doctor`, `team-curate`, `doc-feature`, `doc-capture`, `doc-adr`, `doc-audit`, `audit-memory`, `scratch` (mid-session notes), `recall` (search prior sessions), `glossary-check`, `update-docs`, `write-ticket`, `write-tech-plan`, `write-product-doc`, `write-pr-description`, `write-e2e-test-plan`, `reply-to-qa` *(plus `SHARED.md` — shared content, not a skill)* |
| **4 agents** | `architect` (read-only design), `explore` (read-only investigation), `planner` (write plans, dispatched via `context: fork` from `plan` skill), `team-reviewer` (discipline-check verdict) |
| **5 handlers across 4 hook events** | `SessionStart` → `session-start.sh` · `UserPromptSubmit` → `user-prompt-submit.sh` · `PreToolUse:Bash` → `scan-destructive.sh` · `PostToolUse:Write|Edit` → `review-required.sh` + `capture-nudge.sh` |
| **4 templates** | `CLAUDE.md.global.template`, `CLAUDE.md.project.template`, `glossary.md.template`, `settings.json.template` |
| **lib/triggers.sh** | canonical trigger patterns — single source of truth for what fires which skill |
| **setup/** | OS-level integration (run once per machine): `bootstrap.sh` (pre-flight) · `install.sh` (statusline + CLAUDE.md + settings.json merge) · `statusline.mjs` + launcher · `demo-tarballs.sh` (workshop tool). See [setup/README.md](setup/README.md). |

## How skills auto-fire

Four mechanisms compose so skills fire without manual `/name` invocation:

| layer | mechanism | role |
|---|---|---|
| 1 | Aggressive descriptions (`"MUST use when X"`) in skill frontmatter | trigger surface in the registry |
| 2 | `using-team-setup` meta-skill, always-on | creates Claude's bias to check the catalog |
| 3 | `SessionStart` hook → `additionalContext` priming | primes session-level attention |
| 4 | `UserPromptSubmit` hook with trigger matching | active per-message reminder |

Each layer alone is insufficient. All four = reliable auto-trigger. Tune the catalog by editing `lib/triggers.sh`.

## First-time setup

**Guided (recommended):** `/team-setup:bootstrap-new-machine` — wizard that runs through audit + curate + verify in order, with confirmation at each phase.

**Manual:** invoke the underlying skills directly:

```bash
/team-setup:team-doctor      # read-only audit of your ~/.claude/
/team-setup:team-curate      # interactive: propose plan → confirm per file → apply
```

Both idempotent. Re-run anytime to reconcile drift. The curate flow asks per-item before applying anything.

Pre-flight (outside Claude): `bash setup/bootstrap.sh` from the cloned repo verifies dependencies (bash 4+, git, claude CLI) and prints the launch command with platform-specific install hints if anything's missing.

## Daily commands

| user intent | skill / agent |
|---|---|
| "let's build X" / "add a feature" | `team-setup:brainstorm` |
| spec exists, write a plan | `team-setup:plan` *(auto-forks to `planner` subagent)* |
| plan exists, execute it | `team-setup:execute` |
| bug, test failure, unexpected behavior | `team-setup:debug` |
| implementing — test first | `team-setup:tdd` |
| review my changes | `team-setup:discipline-check` → dispatches `team-reviewer` agent |
| explore an unfamiliar codebase area | `explore` agent *(Claude dispatches via Agent tool — not a slash command)* |
| design a new feature architecture | `architect` agent *(Claude dispatches via Agent tool — not a slash command)* |
| scaffold feature docs | `team-setup:doc-feature <name>` |
| capture session work | `team-setup:doc-capture` |
| record a decision | `team-setup:doc-adr` |
| writing artifacts (PR, ticket, etc.) | `team-setup:write-*` |

Full catalog: invoke `team-setup:using-team-setup` for the live list inside Claude.

## Verify it works

After `--plugin-dir` loads:

1. **Plugin loaded?** Run `/plugin` — `team-setup` should appear in the list.
2. **Skills auto-fire?** Type *"let's brainstorm a feature"* — `brainstorm` skill should activate (you'll see it in the response).
3. **Per-message hooks fire?** After any prompt, look for *"REMINDER: ..."* in the response context — that's the `UserPromptSubmit` hook.
4. **SessionStart priming?** Check Claude's first response of a new session — it should mention the plugin catalog.
5. **Full menu?** Type `/team-setup:` (with the colon) — full skill list shows in the slash command menu.

If anything fails, jump to [Troubleshooting](#troubleshooting).

## Platform requirements

| platform | status |
|---|---|
| macOS | native |
| Linux | native |
| Windows | runs under **WSL** — bash hooks; native cmd/PowerShell unsupported |

`.gitattributes` enforces LF on `*.sh`, so cloning on Windows won't break line endings under WSL.

**Dependencies:** `bash` (4+). No `jq`, no `node`, no other tools — the plugin is pure bash + markdown.

## Customization

**Personal overrides take precedence.** Drop a same-named skill into `~/.claude/skills/<skill-name>/` and your version wins. Resolution order: personal → plugin.

**Project tuning** lives in `<repo>/.claude/`. `team-curate` scaffolds these on demand per scope (global / project shared / project local).

**Trigger patterns** are in `lib/triggers.sh` — single canonical source. Edit `match_skill` to add or refine trigger keywords. Both hooks (`SessionStart` and `UserPromptSubmit`) source this file.

## Troubleshooting

| symptom | check |
|---|---|
| Plugin not loaded | `/plugin` should list team-setup. If not: verify `--plugin-dir` path is absolute; restart Claude |
| Skill doesn't auto-fire | Look for `REMINDER: ...` in response after your message — that confirms `UserPromptSubmit` fired. If missing: check `lib/triggers.sh` trigger patterns match your phrasing |
| Hook fails on Windows | Must run inside **WSL** — native cmd/PowerShell can't run bash scripts. Verify `bash --version` works in your shell |
| `SessionStart` priming missing | Open `<session-context>` (first response of session) — should say *"team-setup plugin loaded"* |
| Wrong skill fires | Multiple plugins compete on description ranking. Disable overlapping plugins or use `/team-setup:<name>` explicitly |
| Skills moved / renamed | Restart Claude — plugin discovery happens at session start |

## Architecture

Three discipline principles drive the design:

- **Build before install** — prefer custom skills / hooks / rules over installing plugins; install only when measurably better
- **Layered enforcement** — hard rules at `settings.json` + PreToolUse; medium via PostToolUse nudges; soft via CLAUDE.md principles
- **Feature-grouped docs** — `docs/features/<feature>/{design,plan,notes}.md`; cross-cutting in `docs/{decisions,handoffs}/`

Full design rationale lives in the parent workshop project (the `claude-learnings` repo where this plugin originated). This README intentionally stays self-contained — you don't need anything outside this repo to use the plugin.

## Status

Stable. 22 skills + 4 agents + 5 hooks production-tested in the user's daily workflow. Plan revisions and case study in the parent `claude-learnings` repo.

## License

Currently unlicensed — add a `LICENSE` file before publishing publicly. MIT or Apache 2.0 are sensible defaults for Claude Code plugins.
