---
name: doc-audit
description: Audit `docs/` for drift. Reports stale files (>90 days untouched), broken cross-references, missing ADR numbers, features with code activity but no doc activity. Branch-aware — distinguishes current branch view from main. Read-only; suggests fixes but never writes.
---

# doc-audit

Read-only audit of `docs/`. Reports drift; never writes files.

## Required preparation

1. Run `git branch --show-current`. Record the current branch.
2. List all docs: `find docs -type f -name "*.md"`.
3. For each file, get last-modified date: `stat -f %m <file>` (macOS) or `stat -c %Y <file>` (Linux).
4. If on a feature branch and `main` exists: also note files that exist here but not in main.

## Drift signals

| signal | what to report |
|---|---|
| File untouched >90 days | `stale: <path> (last modified <date>) — verify still current` |
| Cross-reference to non-existent file | `broken ref: <path> references <missing-path>` |
| ADR number gap (e.g. 0001, 0002, 0004 — missing 0003) | `ADR gap: missing 0003 in <location>` |
| Feature folder exists but has no `design.md` or `plan.md` | `incomplete feature: <feature> lacks design or plan` |
| Code in `<area>` modified recently but `docs/<area>.md` untouched | `doc lag: <area> code changed, doc unchanged` |
| Feature folder on this branch but not on main | `in-flight: <feature> (informational, not drift)` |

## Output format

```
DOC AUDIT — branch: <current-branch>

Stale (>90 days):
  - docs/transactions.md (last modified 2026-02-15)

Broken references:
  - docs/features/X/design.md → docs/features/Y/plan.md (Y not found)

Missing:
  - docs/features/Z/ has no design.md or plan.md

ADR gaps:
  - docs/decisions/ jumps from 0007 to 0009 (missing 0008)

Doc lag:
  - app/admin/ modified in last 7 days; docs/architecture.md untouched

In-flight (informational):
  - docs/features/team-setup-plugin/ on this branch, not on main
```

## Suggest, don't fix

- Report findings. Suggest the fix in plain language.
- Do **not** auto-edit files. Drift fixes belong to the user (or `/team-setup:doc-capture` invocation).

## When to run

- Before merging a feature branch — make sure docs are caught up.
- Periodically (monthly) — `team-doctor` invokes this silently and surfaces only if drift detected.
- Before a workshop or onboarding — make sure docs reflect current truth.
