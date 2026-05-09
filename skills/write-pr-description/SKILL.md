---
name: write-pr-description
description: Write PR descriptions matching our team template and tone. Use when creating or summarizing a PR.
---

# Write PR Description

Write PR descriptions that read like a human wrote them — high-level overview, explain non-obvious decisions, use our team language.

## Inputs

- `$ARGUMENTS` — optional branch name, Jira ticket, or context about the changes

## Process

1. Read shared rules: [SHARED.md](../SHARED.md) — tone, terminology
2. Read real examples for tone reference: [../write-ticket/examples/good-tickets.md](../write-ticket/examples/good-tickets.md)
3. Gather context: `git log`, `git diff`, changed files
4. Extract Jira ticket from branch name — branches follow `OL-XXXX-description` or `GENIE-XXXX-description` etc. Build the Jira link: `https://nestiolistings.atlassian.net/browse/<TICKET-ID>`. If branch starts with `OLBP` it's a feature branch for the Onlineleasing Billing & Payments pod (not a ticket branch) — ask the user for the Jira ticket or leave blank.
5. Write the PR description following the rules below
6. Output as copy-pasteable markdown for GitHub UI

## Writing Rules

### Tone — match our ticket language
- "we" language: "we added", "we block", "we already have"
- Describe what happens, not what was coded: "we block fee creation on Rhino ROs" not "added ValidationError raise in _validate_rhino_no_fees"
- Conversational but precise: "Rhino works by presence alone — no fees" not "The Rhino rental option does not utilize fee structures"
- Short sentences. No filler. No corporate-speak.
- Reference domain concepts by name: "deposit eliminator", "SROItem", "carry-over" — same terms as our glossary

### What section — high-level only
- Describe changes in terms of behavior: "we now block X", "we added Y capability"
- 3-5 bullets max — each one a meaningful change a reviewer should understand
- Don't list files. Don't describe code structure. Reviewers can read the diff.
- Use the same phrasing style as our ticket requirements: "When we fail to calculate X, fall back to Y"

### Why section — explain non-obvious decisions
- Focus on decisions that aren't obvious from reading the code
- Explain trade-offs: "we went with X instead of Y because..."
- Explain coverage: "this validation covers all 4 creation paths because..." (only when the path coverage isn't obvious)
- If something looks wrong but is intentional, explain it here
- Skip obvious motivations — don't explain why we added tests or why validation is good

### How was this tested
- High-level: number of tests, what areas they cover
- Call out non-obvious testing decisions: "we test at the validator level, not MITS level, because MITS already runs ADMIN_RULES"
- If there's a regression suite, mention it passed

### Additional Notes — only non-obvious stuff
- ORM gotchas, migration notes, follow-up work needed
- Skip if there's nothing surprising
- Validation coverage matrix is useful when multiple entry points exist (admin, settings, MITS, bulk uploader)

### What to avoid
- File-by-file changelogs
- Implementation details obvious from the diff
- Repeating the ticket description
- Over-explaining standard patterns
- Long bullet lists — if you have 8+ bullets, you're too detailed
- Robot language: "The system ensures...", "This implementation provides..."
