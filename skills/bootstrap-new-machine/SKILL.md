---
name: bootstrap-new-machine
description: Walks you through first-time team-setup onboarding on this machine — confirm plugin loaded, run team-doctor audit, apply via team-curate, then verify hooks and auto-pickup are working. Explicit invoke only (not auto-fired).
disable-model-invocation: true
---

# bootstrap-new-machine

Manual-invoke wizard for first-time setup of team-setup on a new machine or new project. Walks the user through audit → apply → verify in order.

**Announce at start:** "I'm using `/team-setup:bootstrap-new-machine` to walk you through first-time team-setup. We'll go step by step — confirm before each phase."

## Phase 1 — confirm plugin loaded

Before any setup work, verify team-setup is actually loaded:

1. Tell the user to run `/plugin` (or just check the system reminder shown at session start).
2. Look for `team-setup` in the listed plugins.
3. If missing: "team-setup is not loaded. Restart Claude with `claude --plugin-dir <path-to-team-setup>` and re-invoke this skill."

If loaded, continue.

## Phase 2 — audit current state

Invoke `team-setup:team-doctor` to get a read-only audit of `~/.claude/`:

```
/team-setup:team-doctor
```

Doctor reports:
- What's present, missing, or drifted vs the team baseline
- No changes — diagnostic only

ASK the user: "Doctor's report above. Want to apply the team baseline now via team-curate, or review specific items first?"

WAIT for user response. If they want to review individual items, walk them through one at a time and then re-prompt.

## Phase 3 — apply via team-curate

When user is ready, invoke `team-setup:team-curate`:

```
/team-setup:team-curate
```

Curate is interactive — it proposes a plan, asks confirmation per file, then applies. Pause to let the user respond to each prompt. Don't auto-approve; the user is in control.

Curate handles three scopes:
- **Global** — `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, etc.
- **Project shared** — `<repo>/.claude/`
- **Project local** — `<repo>/.claude/settings.local.json`

ASK the user which scope(s) to curate. WAIT for response.

## Phase 4 — verify

After curate finishes, test that the setup actually works:

1. **Plugin reload check:** Tell the user — "Restart Claude (Ctrl+D, then re-run with `--plugin-dir`) so SessionStart hook picks up the new state."

2. **Auto-pickup test:** Once restarted, the user types something like *"let's brainstorm a feature"* — `team-setup:brainstorm` should auto-fire. Confirm by looking for the skill in the response.

3. **Catalog tour:** Inside Claude, type `/team-setup:` (with the colon) — the slash menu shows the full skill catalog. Run `team-setup:using-team-setup` to see the live list.

If anything fails, refer the user to README §Troubleshooting for the diagnosis order:
- Plugin loaded?
- UserPromptSubmit hook firing?
- SessionStart priming present?
- Trigger pattern matches?

## Phase 5 — handoff

After verification, summarize:
- What got installed (which scopes, which files)
- What's next — daily workflow: `team-setup:doc-feature <name>` to scaffold a feature, then `team-setup:brainstorm` → `team-setup:plan` → `team-setup:execute` for the build cycle
- Where to tune triggers — `lib/triggers.sh`
- Where to override skills — personal `~/.claude/skills/<name>/` takes precedence over plugin

Offer: "Want me to run `team-setup:using-team-setup` now to show you the daily commands?"

## Don't

- Skip phases — each one builds on the previous. Don't jump to verify without curate.
- Auto-approve curate prompts — the user must confirm each scope.
- Reinvent the audit logic — use `team-doctor` (read-only) and `team-curate` (apply). This skill is the orchestrator, not the implementer.
- Continue if Phase 1 fails — without the plugin loaded, nothing downstream works.
