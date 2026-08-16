# Requirements brief template

A requirements spec, not a report and not a plan. Two audiences read it: a human
skimming the issue, and the implementation agent, which sees this **instead of**
the original request.

**Hard budget: 30 lines.** If it does not fit, the request is too large — say so
and ask which slice to build first. Drop any section that carries nothing;
never pad one to look complete.

Write in assertions. No preamble, no restating the issue, no "this change will".

**Nothing about implementation.** No file paths, symbols, endpoint or class
names, schemas, migrations, task lists, phases, or approaches. The implementer
explores for itself; a hint from here only anchors it to what you happened to
read.

```markdown
## Problem

What the user cannot do today. 1–3 sentences.

## Requirements

- Imperative, user-visible statements. One per line, 5 max.
- Include the failure path when it is not obvious.

## Out of scope

- Only what the request implied but should not be built now.

## Affected capabilities

- `openspec/specs/<capability>` — what it says today that this changes or extends.

## Acceptance criteria

- [ ] A coach can cancel their own session from the session detail page.
- [ ] Cancelling within 2 hours of start is rejected with a clear message.
- [ ] A cancelled session no longer counts towards the monthly bill.

## Assumptions

- <product decision made without confirmation> — <what breaks if wrong>.
```

Rules that matter:

- **Requirements** are what must be true. **Acceptance criteria** are how to
  check it, phrased as something a user or an API caller can observe. Do not
  write the same sentence twice in both.
- **Affected capabilities** cites OpenSpec capabilities you actually read —
  never code paths, never recollection. Omit the section if none applies.
- **Assumptions** are product decisions you made instead of asking. They must
  reach the OpenSpec proposal so they surface in review, so keep them explicit.
  A technical choice is not an assumption to record here; it is the
  implementer's call.
- Anything already answered in the comment thread is folded in silently as a
  requirement or a fact. Do not transcribe the Q&A — the thread is above.
- The test for every line: *would it still be true if the code were rewritten
  from scratch?* If not, delete it.
