---
name: update-docs
description: Update local docs to reflect recent work — captures domain knowledge discovered during feature development. Use after completing feature work, when user says "update docs", or when domain knowledge needs to be recorded.
---

# Update Docs

Capture domain knowledge discovered during feature work into local docs. These are living documents that aggregate knowledge from all branches, tickets, and conversations.

## Inputs

- `$ARGUMENTS` — optional: specific topic, branch, or area to update. If empty, infer from current branch and recent conversation.

## Critical Rules

1. **NEVER delete existing content** — docs accumulate knowledge across branches. Content from other features MUST be preserved even if unrelated to current work.
2. **Additive updates only** — add new sections, update existing ones, correct errors. Never regenerate from scratch.
3. **Update, don't duplicate** — if a topic is already documented, update that section. Don't create new docs for existing topics.
4. **Branch-agnostic** — local docs persist across branches. Knowledge from any branch belongs here.

## Process

1. Read shared rules: [SHARED.md](../SHARED.md) — tone, terminology
2. If a glossary exists, read it
3. Identify what was learned in this session:
   - Check git diff for what changed on the current branch
   - Review conversation context for domain knowledge, product decisions, confirmed requirements
   - Check if any new terminology was introduced
4. For each piece of new knowledge, find the right home in existing docs or create a new doc ONLY if it doesn't fit in any existing one
5. Read the target doc(s) fully before editing
6. Make the updates — preserving all existing content
7. Verify no content was lost (check line counts, section headers)

## What to Capture

| Source | What to Extract |
|--------|----------------|
| Product decisions | Requirements with source attribution (who confirmed, when) |
| Codebase discoveries | How something actually works vs how we thought it worked |
| Behavioral rules | Per-transaction-type matrices, edge cases, guard conditions |
| New terminology | Terms the team started using that aren't in the glossary |
| Confirmed gaps | Things we confirmed don't work or aren't supported |
| Bug discoveries | Behavioral issues found during development |

## Writing Rules

- Follow the tone from SHARED.md: "we" language, short sentences, no filler
- Every requirement needs a source — who confirmed it, when, what context
- Use matrices for cross-transaction-type comparisons
- Use requirement-with-example pattern for non-obvious behavior
- Mark unconfirmed items with TODO
- Keep docs compact — prefer tables and matrices over paragraphs

## After Updating

- Report what was added/changed and which files were modified
- If new terminology was added to the glossary, mention it
- If a new doc was created, explain why it didn't fit in existing docs
