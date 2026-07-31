---
name: implement-python-ticket
description: Implement a Jira ticket in a Python backend end-to-end and open a draft GitLab MR. Enforces a gated flow — clarify requirements → implementation plan (approval gate) → code → tests (one per changed path & acceptance criterion) → draft MR following Inspectorio GIT conventions. Use when given a Jira ticket ID/URL and asked to implement it, "pick up ticket ...", or "open an MR for ...".
version: 1.0.0
---

# Implement Python Ticket

Take a Jira ticket from requirement to a **draft** GitLab MR in a Python backend, with quality gates that match Inspectorio engineering standards.

## Core principle

This is a **gated workflow, not a one-shot generator.** Two hard STOP gates exist. Do not
cross them without explicit user sign-off. Crossing a gate silently is the main failure mode
this skill exists to prevent.

```
Phase 1  Clarify requirements   (ticket only — do NOT read code yet)
             │  (restate + open questions + readiness call)
             ▼
========= GATE A: requirements confirmed =========   ← STOP, wait for user
             ▼
Phase 2  Implementation plan
             │  (files, approach, test list, risks)
             ▼
========= GATE B: plan approved =================   ← STOP, wait for user
             ▼
Phase 3  Code
             ▼
Phase 4  Tests   (a test for every changed path + acceptance criterion)
             ▼
Phase 5  Code review  (run the available code-review skill/agent; fix findings)
             ▼
Phase 6  Draft MR  (GitLab CLI, GIT conventions, status: Draft)
```

## Working rules

These sharpen how the phases below are executed:

- **Goal-driven execution (applies across all phases).** Treat the ticket's acceptance
  criteria as the success definition, and loop until every one is verified — don't stop
  at "steps done." In Phase 4 this means the diff→test map must show each criterion
  covered; in Phase 5, fix findings until the review is clean, not just run once.

- **Surface conflicts, don't average them.** If two patterns in the codebase contradict
  (e.g. two ways to structure a service call), pick one — prefer the more recent or the
  better-tested — state why in the plan, and flag the other for the reviewer. Never blend
  two conflicting patterns into a hybrid. This is a plan-time (Phase 2) call; if it can't
  be resolved from the code, raise it at GATE A/B as data.

- **Tests verify intent, not just behavior.** Each test must encode *why* the behavior
  matters (the acceptance criterion it protects), not merely *what* the code does now. A
  test that can't fail when the business rule changes is worthless — assert on the fields
  that carry the rule (reinforces testing-standards guideline #7 on over-specification).

## Context isolation / orchestration

To keep the **main session's context small**, the read/explore/execute-heavy phases run in
**isolated subagents** that return only compact artifacts; the main session orchestrates and owns
everything interactive.

- **Main session owns:** Phase 1 (needs the user + Atlassian MCP), **GATE A**, **GATE B**, and
  Phase 6 (final MR + report).
- **Dispatched to subagents:** Phase 2 (a read-only `Plan` agent, dispatched with
  `model: "sonnet"` → returns a compact plan),
  Phase 3 (a `general-purpose` agent → writes code, returns a changed-files summary), Phase 4 (a
  separate `general-purpose` agent → writes/runs tests, returns a diff→test map). Phase 5 already
  dispatches a review agent.
- **Subagents share the working tree** (default filesystem — *not* an isolated worktree), so code
  and tests persist on the branch the main session later pushes.
- **Subagents never cross a gate.** They cannot ask the user; a subagent that hits a new ambiguity
  **returns it as data** and the main session raises it. The main session rebuilds state between
  write-phases from `git diff` / `git status`, not from the subagents' transcripts.

See `references/workflow.md` for the per-phase dispatch blocks (agent type, handoff, return shape).

## When to use

- User gives a Jira ticket ID or URL and asks to implement it.
- "Pick up / work on / implement <TICKET>."
- "Open a (draft) MR for <TICKET>."

Not for: pure code review (use `/code-review`), resolving existing MR comments
(use `/resolve-mr-comments`), or non-Python work.

## Prerequisites (check once, early)

- Jira reachable via your Atlassian MCP tools (per your global CLAUDE.md routing) — used to read
  the ticket.
- The GitLab CLI is authenticated — used to open the MR.
- Inside a git repo with a GitLab `origin`. Default target branch is usually `master`/`main` —
  confirm which one this repo uses.

If a prerequisite is missing, say so and stop — do not fabricate a ticket or a fake MR.

## The phases

Follow `references/workflow.md` for the exact steps and commands of each phase. Summary:

1. **Clarify requirements — from the ticket only.** *(main session)* Fetch the ticket via your Atlassian MCP
   tools. **Do not read the code yet** — judging the ticket on its own
   surfaces vagueness the author must resolve, before code-reading tempts you to silently assume
   what it "probably means." Restate the goal, acceptance criteria, scope, and **assumptions**;
   list every ambiguity/gap as a numbered open question; and give a **readiness call** (ready as
   written, or needs clarification). **GATE A:** wait for the user to confirm/answer before
   planning.

2. **Implementation plan.** *(run in a `Plan` subagent with `model: "sonnet"`)* *Now* explore the codebase. Produce a concise plan: files to change,
   the approach, edge cases, and the **explicit list of test cases** you will write (one behavior
   each). Call out risks and anything out of scope. If the code exposes a new ambiguity, return
   to GATE A. **GATE B:** wait for explicit approval ("approved", "go") before writing any code.

3. **Code.** *(run in a `general-purpose` subagent; main session creates the branch first)*
   Create the branch (`references/git-conventions.md`), then implement the smallest
   change that satisfies the approved plan, to the standards in
   `references/engineering-practices.md` (layered separation, SOLID applied pragmatically, clean
   names, real error handling, security, edge cases). Match surrounding code style. No unrelated
   edits.

4. **Tests.** *(run in a separate `general-purpose` subagent)* Write tests to the standards in `references/testing-standards.md`. Aim: **a test
   for every new/changed code path and every acceptance criterion** — cover happy path, each
   branch/error path, and the in-scope edge cases. Verify by *reasoning through the diff*
   (map each change → its test), not by running a coverage tool; running local diff-coverage is
   impractical here. Tests must run green and be clear (one behavior per test, AAA,
   self-sufficient, deterministic). AAA is layout, not labels — never emit `# Arrange` /
   `# Act` / `# Assert` (or Given/When/Then) comments.

5. **Code review.** Before the MR goes up, review the new code with the **available code-review
   skill/agent** — discover it in this order and use the first that exists:
   (a) a repo-local `.claude/skills/code-review/` skill, (b) a global `code-review` skill or a
   `code-reviewer`/`code-review` agent, (c) fall back to the built-in `/code-review`. Scout edge
   cases, run the review on the branch diff, and **fix Critical/Important findings before Phase 6.**
   See `references/workflow.md`.

6. **Draft MR.** *(main session)* Commit per GIT conventions, push, and open the MR as **Draft** with the GitLab
   CLI (`references/git-conventions.md`). Link the ticket. Report the MR URL.

## Reference navigation

- `references/workflow.md` — step-by-step for all phases, with exact commands and the
  gate-handling protocol.
- `references/engineering-practices.md` — how to write the code (Phase 3): layered separation,
  SOLID applied pragmatically, clean code, error handling, security, edge cases, diff hygiene.
- `references/testing-standards.md` — Inspectorio Unit Testing Best Practices (the 8
  guidelines, AAA, what-not-to-test, sight-be conventions) + the coverage-by-reasoning procedure.
- `references/git-conventions.md` — branch naming, commit format, and the GitLab CLI draft-MR
  steps + MR description template.

## Non-negotiables

- **Never cross GATE A or GATE B without user sign-off.** When unsure whether you have it, ask.
- **Subagents never cross a gate.** Gate sign-off happens only in the main session; a dispatched
  subagent that hits a new ambiguity returns it as data — it must not ask the user itself.
- **Test completeness is judged by reasoning, not a coverage tool.** Every new/changed code path
  (happy path, each branch, each error path) and every acceptance criterion must have a
  corresponding test. Confirm this by mapping the diff to tests, and say so honestly — do not
  claim a measured coverage percentage you did not measure. If a path is deliberately left
  untested, name it and justify it.
- **MR opens as Draft.** Never mark ready-for-review automatically.
- Report outcomes faithfully: if tests fail or a step is skipped, say so with the output.
