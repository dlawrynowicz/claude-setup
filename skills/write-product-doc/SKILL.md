---
name: write-product-doc
description: Write product requirements documentation — the engineering source of truth. Captures what Product decided, who confirmed it, and when. Use when documenting domain areas, capturing grooming decisions, or building requirements docs from codebase research.
---

# Write Product Doc

Write product requirements docs that engineers maintain as the source of truth. Every requirement traces back to who confirmed it and when — accountability baked in.

Knowledge gets discovered across different feature branches, tickets, standups, and grooming sessions. This doc is the single place where it all gets aggregated — regardless of which branch or sprint it came from. When you learn something new about a domain while working on a feature, add it here with a source.

## Inputs

- `$ARGUMENTS` — domain area, topic, or meeting notes to document

## Process

1. Read shared rules: [SHARED.md](../SHARED.md) — tone, terminology, domain knowledge
2. Read relevant local docs for existing domain knowledge — **start from what's already documented**
3. Read real examples for tone: [examples/good-product-docs.md](examples/good-product-docs.md)
4. Only research the codebase for what's missing from existing docs
5. Write the doc using the patterns and rules below
6. Review using the checklist at the bottom

## Document Structure

```markdown
# <Domain area> documentation

> Work-in-progress documentation.
> Goals: keep track of all Product requirements,
> be the technical source of truth about how it works.

----

# Product requirements

## <Domain section> (e.g. Application, Renewal, Transfer)

### <Topic> (e.g. Scheduled price change, Carry-over logic)

- Requirement bullet
    - Example (if needed)
    - Source

----

# Data model

### <Concept> (e.g. Configuration layer, Quote, Lease)

Explanation with concrete example showing real instances.

----

# Technical notes

### <Topic> (e.g. Application fee, Holding deposit)

How things work under the hood — model fields, code references,
key logic details engineers need when implementing.
```

### Section Rules

- **Product requirements** always comes first — it's the "what"
- **Data model** comes second — it's the "how it's stored"
- **Technical notes** comes last — it's the "how it works under the hood"
- Not every doc needs all three sections. A small domain might just be Product requirements
- Domain sections are organized by **transaction type or domain concept**, not by feature or ticket
- Within a section, topics are grouped by what an engineer would look up together
- Each doc starts with the WIP callout — these are living documents, not finished specs

## Writing Patterns

### 1. Requirement-with-example (default pattern)
Every product requirement is a bullet. When behavior isn't obvious, add a concrete example underneath (Given/When/Then). Always include a Source.

### 2. Behavioral matrix
When multiple transaction types or scenarios have different behaviors, use a table instead of repeating bullets.

### 3. Decision table
For complex conditional logic ("if X and Y, then Z") with multiple inputs and outcomes.

### 4. Data model explanation
Walk through a concrete example with real instances — "if we have a Dog rental option with two fees, here are the instances that get created."

### 5. Negative requirement
Explicitly call out what we do NOT support, so engineers don't waste time investigating.

### 6. Flow summary
For multi-step processes, numbered steps with brief explanations.

## Source Attribution

- Every requirement needs a Source — who confirmed it, when, and context
- Format: `Confirmed by [name] during [event] on [date]` or `Requirements from this ticket: [link]`
- JIRA ticket links: `https://nestiolistings.atlassian.net/browse/<TICKET-ID>`
- If confirmed verbally (standup, call), say so: "Confirmed during a call with the team January 14, 2026"
- Sources create accountability — without them, requirements are just opinions

## Formatting (JIRA-friendly)

- Output should be JIRA-friendly markdown
- Use JIRA features:
  - `{expand:Title}...{expand}` for expandable sections
  - `----` for dividers between major sections
  - `{info}`, `{warning}`, `{note}` panels for callouts
- Source sections should be expandable — important for traceability but shouldn't clutter the reading flow
- Keep the main reading path clean — details go in expandable sections

## Highlighting Gaps

- Mark unconfirmed requirements: `{warning}Unconfirmed — needs Product sign-off{warning}`
- Mark undocumented areas: `{info}TODO: No requirements documented for [topic]. Needs investigation.{info}`
- Mark contradictions: `{warning}This contradicts [other requirement] — needs resolution{warning}`
- Gaps are valuable — a doc that shows what we don't know is more useful than one that pretends we know everything

## Review Checklist

After writing, check each section for:
- Missing sources — every requirement needs attribution
- Missing examples — if a requirement has non-obvious behavior, it needs a concrete example
- Missing negative requirements — are there flows people might assume work but don't?
- Incomplete scope — "this applies to all transaction types" — did you list which ones?
- Stale terminology — check against glossary
- Contradictions — does any requirement conflict with another?

## What to Avoid

- Corporate-speak: "The system shall ensure that..."
- Undocumented requirements — if there's no source, it's not a requirement
- Mixing "what the code does" with "what Product wants" without distinguishing them
- Walls of text — if you have 5+ similar bullets, use a matrix or table instead
- Hiding unknowns — flag gaps explicitly rather than leaving them out
