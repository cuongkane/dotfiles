Write a concise, objective, professional solution proposal (MR description, Jira ticket, or Slack post) for: $ARGUMENTS

If no topic is given, use the work done in the current session/branch.

## Structure (always this order)

```markdown
## Context
<1-2 sentences: the system/repo, who works on it, why this area matters. State scale with real numbers (teams, tests, users).>

## Problem
<1-2 sentences: what is wrong today, with measured numbers (time, count, size) — not adjectives. End with references: ticket ID, analysis doc links.>

## Impact
- <Labeled bullets in "**Category**: consequence" form, e.g. "Bad Developer Experience: ...", "Less Productivity: ...">
- <Order by severity, most important first; tag minor ones "(minor)">

## Solution
<One sentence stating the approach. Then break into sequential phases if there is ordering:>

Phase 1: <name> — <what it does, comma-separated responsibilities>
Phase 2: In parallel:
- **`job_or_component`** — <what it does; include exact commands/paths in backticks>
Phase 3:
- **`final_step`** — <gate/verification; state what guarantee is preserved and why it is safe>

- **<Cross-cutting change>** — <e.g. resource right-sizing, with before → after numbers>

## Results
- <Measured or bounded outcome with numbers; if not yet measured, state the bound honestly ("bounded by X, roughly halved") and name the follow-up>
- <What did NOT change: no tests removed, same gates, no new risk>

## Notes for reviewers
- <Behavior changes, removed artifacts, anything needing confirmation — invite correction ("if it's needed elsewhere, please lemme know")>
```

## Style rules

- Straight to the point: no filler, no marketing tone, no "we are excited".
- Every claim carries a number or a reference; if unverified, say so explicitly rather than overpromising.
- Bold the key numbers and job/component names; backticks for commands, paths, and identifiers.
- Prefer short labeled bullets over paragraphs; one idea per bullet.
- Keep total length under ~40 lines; cut detail that doesn't change the reader's decision.
- Gather real numbers from the session, git diff, CI logs, or linked tickets before writing — never invent them.

## Output

Return the proposal in a single markdown code block ready to paste, then at most 2 lines flagging any numbers the user should verify or fill in.
