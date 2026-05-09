---
name: reply-to-qa
description: Write replies to QA engineers, PMs, or teammates about bug reports, questions, or behavior clarifications. Use when drafting responses about expected vs actual behavior.
---

# Reply to QA / Team

Write replies that read like a teammate explaining behavior — direct, factual, no robot-speak.

## Inputs

- `$ARGUMENTS` — the bug report, question, or behavior to respond to

## Process

1. Read shared rules: [SHARED.md](../SHARED.md) — tone, terminology
2. Understand the reported behavior and whether it's a bug or expected
3. Write the reply following the rules below

## Writing Rules

### Tone — same as our tickets and PRs
- "we" language: "we filter", "we keep", "we only exclude"
- Describe behavior as fact: "Rhino filters refundable deposits — non-refundable fees stay visible"
- Short sentences. No filler. No hedging.
- Reference domain concepts by name: "deposit alternative", "SROItemFee", "leasing category"
- Don't over-explain — one clear sentence beats three cautious ones

### Structure
- Lead with the answer: working as expected, confirmed bug, or needs investigation
- Explain the behavior in 2-3 sentences max — what we do and why
- If relevant, include the filtering/logic matrix so they can verify
- If it's a config issue, point to where the setting lives
- End with next steps if any — "if the fee should be a deposit, mark it refundable in RO settings"

### Output format
- Always output inside a markdown code block so the user can copy-paste directly into JIRA or Slack
- Use JIRA-compatible markdown: `*bold*` for bold, `||heading||` for table headers, `|cell|` for table rows
- No HTML tags, no GitHub-flavored markdown — JIRA/Slack only

### What to avoid
- Apologetic tone — if it's working correctly, say so
- Code references — they don't need file paths or method names
- Over-qualifying: "I believe", "it seems like", "it might be"
- Walls of text — keep it scannable
