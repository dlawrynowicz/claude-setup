---
name: glossary-check
description: Scan recently-modified files (`.md`, source code) for terminology drift against the project's `docs/glossary.md`. Reports violations as warnings; never auto-fixes. Use periodically or before merging a feature branch. On-demand companion to project-level hookify rules (which fire automatically on every file write).
---

# glossary-check

Read-only scan. Reports terminology drift; never writes.

## Required preparation

1. Read `<repo>/docs/glossary.md` if present. Parse the mapping table — every `term → preferred` line.
2. If no glossary exists, exit cleanly: `"No docs/glossary.md found — skipping. Create one via /team-setup:doc-capture or copy from team-setup/templates/glossary.md.template."`
3. Decide scan targets:
   - Default: files modified in the last 7 days (`find . -mtime -7 -type f`)
   - Or: current branch's diff vs `main` (`git diff --name-only main`)
   - Filter to `.md`, `.txt`, `.py`, `.ts`, `.tsx`, `.js`, `.jsx`

## Build the violation list

For each glossary entry of the form `<bad-term> → <preferred-term>`:
- The LEFT side is what we're flagging.
- For each scan-target file, search for occurrences of the bad term.
- Record: file path, line number, the term found, the preferred replacement.

## Output

```
GLOSSARY-CHECK — <N> files scanned, <K> drift signals

⚠ Drift detected:
  - <path>:<line> — "<found>" → use "<preferred>"
  - ...

✓ No drift in <list of clean files>
```

## Don't

- Don't auto-fix. Suggest replacements; the user applies them.
- Don't flag terms NOT in the glossary.
- Don't fail noisily if the glossary doesn't exist — report skipped and exit.
- Don't double-flag (if a file contains 5 occurrences of one bad term, list once with a count).

## Manual vs hookify

Project-level hookify rules (e.g., `<repo>/.claude/hookify.terminology.local.md`) fire on **every** file write — automatic, immediate, per-edit.

This skill is for **periodic batch scans** across the repo (whole-branch pre-merge sweep, recently-modified-files scan, etc.). The two complement each other.
