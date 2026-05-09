---
name: using-team-setup
description: MUST use when starting any conversation — establishes how to find and invoke team-setup skills before any response, including clarifying questions. If you think there is even a 1% chance a team-setup skill applies to what you're doing, you ABSOLUTELY MUST invoke it via the Skill tool BEFORE doing the work.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent (your context begins with an agent system prompt — e.g. "You are a code reviewer...", "You are a senior software architect..."), skip this skill. The agent context is already focused, and the meta-skill would cause recursive overhead.
</SUBAGENT-STOP>

# using-team-setup

**Vendored from `superpowers:using-superpowers`** — adapted as the meta-trigger for the team-setup skill ecosystem. Mirrors the upstream pattern of forcing skill invocation through imperative framing. This is the load-bearing piece that makes individual team-setup skills actually fire instead of Claude defaulting to "explore first."

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a team-setup skill applies to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction priority

team-setup skills override default Claude Code behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (`CLAUDE.md`, `AGENTS.md`, direct requests) — highest priority
2. **team-setup skills** — override default system behavior where they conflict
3. **Default Claude Code behavior** — lowest priority

If `CLAUDE.md` says "don't use TDD" and a team-setup skill says "always use TDD," follow the user's instructions. The user is in control.

## How to access skills

Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you — follow it directly. Never use the Read tool on skill files.

## When to invoke

**Invoke relevant skills BEFORE any response or action.** Even a 1% chance a skill might apply means you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

This includes:
- Before answering questions
- Before exploring the codebase
- Before running commands
- Before clarifying with the user

The skill tells you HOW to explore, ask, and act. Skip the skill check at your own peril.

## team-setup skill catalog

Match user intent to skill:

| trigger / user intent | skill |
|---|---|
| Building a feature, adding functionality, modifying behavior, designing changes | `team-setup:brainstorm` |
| Spec/design exists, need an implementation plan | `team-setup:plan` |
| Plan exists, need to execute | `team-setup:execute` |
| Implementing any feature or bugfix (TDD cycle) | `team-setup:tdd` |
| Bug, test failure, unexpected behavior, debugging | `team-setup:debug` |
| Reviewing code against TDD/DRY/SOLID/security | `team-setup:discipline-check` skill (which dispatches the `team-reviewer` agent) |
| Exploring an unfamiliar codebase area | `team-setup:explore` agent (dispatch via Agent tool) |
| Designing a new feature architecture | `team-setup:architect` agent (dispatch via Agent tool) |
| Capturing session work into docs | `team-setup:doc-capture` |
| Scaffolding a new feature folder | `team-setup:doc-feature` |
| Recording an architectural decision | `team-setup:doc-adr` |
| Auditing `docs/` for drift | `team-setup:doc-audit` |
| Auditing user's `~/.claude/` setup | `team-setup:team-doctor` |
| Applying the team baseline (audit + apply) | `team-setup:team-curate` |
| Auditing memory dir for bloat | `team-setup:audit-memory` |
| Checking files for glossary drift | `team-setup:glossary-check` |
| Writing a JIRA ticket | `team-setup:write-ticket` |
| Writing a technical plan | `team-setup:write-tech-plan` |
| Writing product requirements | `team-setup:write-product-doc` |
| Writing a PR description | `team-setup:write-pr-description` |
| Writing an E2E test plan | `team-setup:write-e2e-test-plan` |
| Replying to QA | `team-setup:reply-to-qa` |
| Updating local docs | `team-setup:update-docs` |

## Red flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---|---|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## Skill priority

When multiple skills could apply, use this order:

1. **Process skills first** (`brainstorm`, `debug`) — these determine HOW to approach the task
2. **Implementation skills second** (`execute`, `tdd`) — these guide execution
3. **Capture skills last** (`doc-capture`, `doc-adr`) — these record after the fact

- "Let's build X" → `brainstorm` first, then `plan`, then `execute`.
- "Fix this bug" → `debug` first, then `tdd`-driven fix, then `discipline-check`.
- "Add feature Y to project" → `brainstorm` first (don't jump to implementation).

## Skill types

**Rigid** (`team-setup:tdd`, `team-setup:debug`): follow exactly. Don't adapt away discipline. These skills self-declare as rigid in their descriptions ("rigid recipe", "Iron Law").

**Flexible** (`team-setup:brainstorm`, `team-setup:plan`, `team-setup:execute`): adapt principles to context — but only where the skill explicitly invites adaptation.

When in doubt, default to following the skill body exactly. Skills tell you when adaptation is appropriate.

## Skill execution mode

Most skills run inline on the main thread. `team-setup:plan` runs in a forked subagent (`team-setup:planner`) per [ADR 0006](../../docs/decisions/0006-skill-execution-mode.md) and Anthropic's [`context: fork`](https://code.claude.com/docs/en/skills#run-skills-in-a-subagent) pattern — the skill body becomes the agent prompt; the agent writes the plan in isolation and returns a summary. Backgroundable, doesn't bloat main-thread context. Interactive skills (`brainstorm`, `tdd`, `execute`, `debug`) stay inline because they need live user dialogue + tool approvals.

## User instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows. The user telling you to add a feature is precisely when `brainstorm` should fire.
