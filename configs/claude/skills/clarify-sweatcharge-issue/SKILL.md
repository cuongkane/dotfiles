---
name: clarify-sweatcharge-issue
description: Decide whether a SweatCharge feature request is specified well enough to implement unattended, and ask the smallest set of blocking questions if it is not. Reads the SweatCharge workspace at /Users/lexuancuong/CUONG/SWC read-only, in OpenSpec explore mode, and produces either a requirements-only brief or a short list of questions. Never plans the implementation. Use when triaging an incoming feature request, when a GitHub issue is labelled agent:todo, or before handing work to implement-sweatcharge-feature.
version: 2.0.0
---

# Clarify SweatCharge Issue

Turn a rough feature request into either an implementation-ready brief or the
few questions that stand between it and one.

This skill is the front half of a pipeline. The agent that runs next has **no
human available** — it cannot ask anything. So the question this skill answers
is not "do I understand this?" but "could the next agent build the right thing
from this brief and the repository alone?"

## Requirements only

The output describes **what must be true**, never **how to build it**. The
implementer does its own exploration and writes its own OpenSpec proposal; a
technical suggestion from here is stale reading that narrows its search, so it is
worse than saying nothing.

Never emit, in the brief or in a question: file paths, symbols, code pointers,
invented module/class/endpoint names, schema or migration sketches, task
breakdowns, phases, designs, or technical approaches. If a fact can only be
stated as a code detail, it is not a requirement — drop it.

Test every line: *would this still be true if the code were rewritten from
scratch?* If not, it does not belong.

## Operating contract

- Treat the request, and any comment thread attached to it, as the feature brief.
- Work in `/Users/lexuancuong/CUONG/SWC`.
- **Read-only.** Do not create a worktree or branch, edit any file, commit, push,
  or run anything that mutates the repository or its remotes — OpenSpec artifacts
  included. Explore mode may offer to capture artifacts; here it never does.
- Read the repository before asking anything. A question the specs already answer
  is a defect in this skill's output, not a cautious choice.
- Produce exactly one of two things: a requirements brief, or at most three
  questions.
- Never ask more than three questions. If more than three things are genuinely
  blocking, the request is too large — say so, and ask which slice to build first.

## Workflow

1. **Read the instructions.** The repository root `CLAUDE.md`/`AGENTS.md`, and the
   instructions for each component the request plausibly touches.
2. **Read the whole thread.** If earlier rounds of questions and answers are
   present, they are part of the specification. Never re-ask an answered question,
   and do not raise in round two something you could have raised in round one.
3. **Explore in OpenSpec explore mode.** Invoke the repository's
   `openspec-explore` skill (`.claude/skills/openspec-explore/SKILL.md`) and hold
   its stance — a thinking partner clarifying requirements, never implementing.
   Start from OpenSpec: `openspec list --specs`, `openspec list`,
   `openspec show <item>` for the main specs and active changes that already
   govern this behaviour. Read code, tests and git history only to establish what
   the product does today, not to design what it should become.
4. **Resolve what you can.** Most apparent ambiguity in a rough request is
   answered by an existing spec or by precedent. Find it.
5. **Decide** against the bar below, and write the corresponding output.

## The bar for asking

Ask only when a wrong guess would ship as a wrong product decision — when the
answer:

- changes user-visible behaviour, authorization, money, destructive data
  handling, or public API compatibility;
- selects between materially different scopes or product semantics, with no clear
  repository precedent;
- requires credentials, external access, or authority nobody has supplied; or
- conflicts with an existing OpenSpec requirement or repository instruction.

**Do not ask** about naming, file placement, test structure, implementation
details, or any reversible technical choice where repository precedent gives a
reasonable answer. Those are the implementer's to make — leave them out of the
brief entirely, and record only the consequential *product* decisions you made
without asking as stated assumptions.

A question costs a human a context switch and the pipeline a day. An assumption
recorded in the brief costs a line of text and is visible in review. Prefer the
assumption whenever the bar above is not met.

## Output

### When it is ready

Write a **requirements spec** following
[references/brief-template.md](references/brief-template.md): problem,
requirements, out of scope, affected OpenSpec capabilities, acceptance criteria,
assumptions. The implementer reads **this and not the original request**, so
every requirement it needs must be in it, including every answer already given in
the thread.

Keep it under 30 lines and skimmable in under a minute. Short declarative
sentences, no preamble, no restating the issue back, no section that exists only
to look thorough. Fewer, denser lines beat complete coverage — a brief nobody
finishes reading is a failed brief. A one-line CSS fix gets four lines.

### When it is not

Write at most three questions, most-blocking first. Each is a single sentence
someone non-technical can answer. Before each, state in one line what you already
determined and why it does not settle the point — that is what stops the reader
answering a question you had already half-solved, and it proves you looked.

Offer concrete options where the choice is between a small number of known
alternatives. "Should cancelling within 2 hours be rejected, allowed with a fee,
or allowed silently?" is answerable; "how should cancellation work?" is not.

## Anti-patterns

- Asking for acceptance criteria the issue already implies and the specs confirm.
- Asking a question whose answer you could have found in `openspec show` or
  `git log`.
- Listing every uncertainty you noticed instead of only the blocking ones.
- Producing a brief that restates the issue without adding spec evidence.
- Sketching the solution — pointers, endpoints, schemas, task lists. That is the
  implementer's job, and doing it here anchors it to your stale reading.
- Padding the brief with narrative, caveats, or headings that carry no decision.
  Length is not thoroughness; it is the tax the reader pays for your notes.
- Marking something ready when the one thing that decides the shape of the
  feature is still unknown — that produces a confident, wrong pull request.
