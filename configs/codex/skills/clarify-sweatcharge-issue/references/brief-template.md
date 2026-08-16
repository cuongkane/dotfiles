# Requirements brief template

A spec, not a report. Two audiences read it: a human skimming the issue, and the
implementation agent, which sees this **instead of** the original request.

**Hard budget: 30 lines.** If it does not fit, the request is too large — say so
and ask which slice to build first. Drop any section that carries nothing;
never pad one to look complete.

Write in assertions. No preamble, no restating the issue, no "this change will".

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

- <decision made without confirmation> — <what breaks if wrong>.
```

Rules that matter:

- **Requirements** are what to build. **Acceptance criteria** are how to check
  it. Do not write the same sentence twice in both.
- **Affected capabilities** cites OpenSpec capabilities you actually read. Never
  cite code paths. Omit the section if none applies.
- **Assumptions** are decisions you made instead of asking. They must reach the
  OpenSpec proposal so they surface in review, so keep them explicit.
- Anything already answered in the comment thread is folded in silently as a
  requirement or a fact. Do not transcribe the Q&A — the thread is above.
- Test every line: would it remain true if the code were rewritten from scratch?
  If not, remove it.
