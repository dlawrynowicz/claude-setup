---
name: harvest
description: Turn review findings and user corrections into durable rule changes - use when a review round, PR feedback, or a "you did X again" correction has just landed, or when the user says "learn from this", "so we don't repeat this", "update the skills". Decides whether the lesson needs a new rule, a fixed delivery mechanism, or nothing at all.
---

# harvest

Findings die in the session that produced them. This turns one into a change that fires next time.

## The Iron Law

```
NO NEW RULE UNTIL YOU HAVE SEARCHED FOR THE EXISTING ONE
```

Most repeat mistakes are not missing rules. They are rules that never reached the model at the moment it was writing. Adding a second copy of a rule that already exists makes the file longer, easier to skim, and less likely to be followed - so the next harvest has a worse hit rate than this one.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone and the existing rule set.
2. Know what actually happened. A finding needs a real trigger: a reviewer comment, a failing check, a correction the user typed. "This could be a problem" is not a finding.

## Phase 1 - state the finding as a behaviour

Write one sentence: **what was done, and what should have been done instead.** No file paths, no ticket numbers.

> Wrote a comment justifying why two lines are ordered a certain way, instead of letting the test pin the ordering.

If you cannot write that sentence, you do not have a finding yet. Stop and ask.

## Phase 2 - search before you write

Grep the rule sets for the behaviour, using the *words a rule would use*, not the words the reviewer used:

```
grep -rin "<concept>" skills/SHARED.md skills/*/SKILL.md
grep -rin "<concept>" <project>/.claude/skills/*/SKILL.md
```

Three outcomes, and they lead to completely different work:

| what you find | what it means | what to do |
|---|---|---|
| No rule covers it | genuine gap | Phase 3 - write the rule |
| A rule covers it, and it was loaded | the rule is unclear or unmemorable | Phase 3 - **sharpen the existing rule in place**, never append a second one |
| A rule covers it, and it was never loaded | **delivery failure, not a content gap** | Phase 4 - fix the mechanism |

The third row is the common one and the easiest to miss. Before concluding a rule was ignored, check whether it was ever shown: which skill carries it, what triggers that skill, and whether that trigger fired. A rule in a skill nothing invoked is not a rule the model broke.

## Phase 3 - write or sharpen the rule

Where it goes:

| kind of lesson | home |
|---|---|
| Language- and project-agnostic (naming, comments, tests, decomposition) | `team-setup/skills/SHARED.md` |
| Specific to one language's idioms in this repo | that project's `<lang>-clean-code` skill |
| A domain fact about this codebase | project memory or `docs/` |
| A workflow step people keep skipping | the relevant team-setup skill's recipe |

Prefer team-setup. A rule that only lives in one repo cannot help the next one.

How to write it:

- **Lead with the instruction, then the evidence.** One concrete example from the real finding beats three invented ones. Name the actual symbol, matcher, or value that fooled us.
- **Make it checkable.** "Write readable code" is not a rule. "A helper called once, from one place, belongs inlined in its caller" is.
- **Put it where it will be read at the right moment**, not in the nearest thematic section. A rule about tests belongs where someone writing a test is already looking.
- **Trade length for sharpness.** If you add ten lines, look for ten to cut. A rule set people skim enforces nothing.

## Phase 4 - fix the delivery instead

When the rule already existed and was never shown, editing it changes nothing. Fix why it did not arrive:

- **Trigger miss** - the skill exists but nothing invoked it. Add the phrasing to `lib/triggers.sh`.
- **Hook miss** - the reminder fires on a tool the model was not using. Check the `matcher` in `hooks/hooks.json` against how edits are actually being made; a handler that matches only `Write|Edit` sees nothing in a session that edits through Bash heredocs.
- **Timing miss** - the rule is only checked at review time, so it is applied after the code feels finished. Move it to the write itself.

Verify the fix by replaying the event that should have fired it. A hook you have not run against a real event shape is a guess.

## Phase 5 - apply it to the code in front of you

A harvest that ends at the rule file ships the violation it was written for. The code you wrote earlier this session was written without the rule you just sharpened, and it is still in the diff.

Before reporting: re-read your own changes against that rule and fix what it catches. Not the whole repo - the files you touched this session.

This is the step that decides whether the harvest was worth doing. Sharpening the comment rule and leaving a design-arguing comment three files away is how the same correction arrives twice, and it is the moment the user asks why the mistake keeps repeating.

## Phase 6 - report, don't commit

Show the user:

- the finding, in one sentence
- whether it was a gap, an unclear rule, or a delivery failure - and the grep that decided it
- the exact edit, and what it replaces
- anything you deliberately did not add, and why

Never commit. Never add a rule the user has not seen.

## Don't

- Don't stop at the rule file. Phase 5 is not optional.
- Don't harvest hypotheticals - only things that actually went wrong.
- Don't add a rule without grepping first.
- Don't append a near-duplicate; sharpen the original.
- Don't harvest more than a handful of findings at once. Rules added in bulk read as a checklist and get skimmed as one.
