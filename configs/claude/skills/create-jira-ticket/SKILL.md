---
name: create-jira-ticket
description: Write or rewrite a Jira Story ticket so it describes end-user behavior instead of code. Produces the Inspectorio house format — user-story Problem statement → bulleted Requirement → numbered GIVEN/WHEN/THEN acceptance criteria — silently checked against INVEST and SMART, then edited in place via the Atlassian MCP. Use when asked to create a ticket, write a story, "update this ticket", "make this ticket focus on user behavior", or "add acceptance criteria". For bug tickets use create-jira-bug instead.
version: 1.1.0
---

# Create / Rewrite a Jira Ticket

Turn an intent (or an existing engineer-written ticket) into a ticket a product person can
refine and a QA can test — **described as behavior the user observes, not as the code that
produces it.**

## Core principle

**A ticket states what changes for the user. It does not state how the code does it.**

The single most common failure is a ticket written from the inside out: it opens with a
function name, explains a placeholder constant, and buries the user-visible symptom. Such a
ticket cannot be refined by a PO, cannot be tested by QA, and rots the moment the code is
renamed.

If a reader who has never opened the repo cannot tell **who is affected and what they will
see differently**, the ticket is not done.

## Reference exemplar

`ID2-36261` ("[BE] Store CPSC submission activity into User Profile's Integration logs") is
the house standard. Read it when the format is unclear. Do not copy its content — copy its
shape.

## The format

Always these three sections, in this order. Jira renders markdown, so `**bold**` section
headers and `*` bullets are correct; AC bodies are indented 4 spaces under their bullet.

```markdown
**Problem statement**

As a <role>, I need <capability> so that <outcome>.

<1 short paragraph: what is wrong today, in terms the user feels — what they see,
what they cannot do, what misleads them. No code.>

**Requirement**

<One sentence stating the change in behavior.>

* <Behavior rule.>
* <Behavior rule — including the negative case: what must NOT change / must not be triggered.>
* <Where the user sees the result.>

<Optional: a table of the fields / states / cases that the rule depends on.>

**Acceptance criteria**

* AC1 — <short title of the behavior>

    Given <precondition>, when <event>, then <observable outcome>.

* AC2 — <short title>

    Given ..., when ..., then ...
```

## Rules

### Voice
- **Problem statement** opens with the user-story line (`As a … I need … so that …`), then
  one paragraph of today's pain. Lead with the symptom, not the cause.
- Use the product's own vocabulary. If the codebase calls it a `verdict` but the product
  calls it a *PO compliance review*, the ticket says **PO compliance review** — every time,
  including in table headers. Ask which term the team actually uses if unsure.
- Present tense, active, no marketing tone, no "we are excited".

### No code in the ticket
Strip all of these from prose:

| Don't write | Write instead |
|---|---|
| `dispatch_compliance_review` skips… | "the review is skipped" |
| `_PLACEHOLDER_CACHE_KEY` in `src/…/service.py` | "the result is kept forever" |
| "compute a hash over … plus a logic-version constant" | "reused only while the PO is unchanged" |
| "status resets to `CREATED`" | "the PO is reviewed again on the next run" |
| "the API exposes `cache_key` and `computed_at`" | "the user can see when it was last computed" |
| "derived from `prompts.py` Steps 1-4" | "derived from what the review actually consumes" |

Exceptions, kept deliberately narrow:
- **Column/field names in a data table** are fine — the table is a refinement artifact for
  the implementer, and the names are the contract. Keep the table's rows verbatim if the
  author already vetted them; rename only the header wording to product language.
- A single implementation pointer is acceptable **inside a Requirement bullet** when it names
  the constraint ("reuse the existing audit-log pipeline — no new transport"), never as the
  framing of the problem.

### Requirement bullets
- One behavior rule per bullet. No paragraphs.
- **State the negative case.** "Only these fields count as a change; editing anything else
  must not force a re-run." Half the bugs live in the case nobody wrote down.
- If a mechanism genuinely is the requirement (reuse pipeline X, emit event Y), state it as a
  constraint in one bullet and move on.

### Acceptance criteria
- Numbered `AC1…ACn`, each with a **short title** naming the behavior, then a GIVEN/WHEN/THEN
  body on its own indented line.
- **Lead with GIVEN.** Preconditions first, always.
- One behavior per AC. If an AC needs "and also", split it.
- Every Requirement bullet — including the negative case — must be reachable from some AC.
- THEN must be **observable**: what the user sees, what the system reports, what is stored.
  Not "the fingerprint matches".
- Cover, where they apply: the happy path, the change/trigger path, the *no-op* path, the
  bulk/global case, and what the user can see about freshness or history.

### Title
The summary must match the content and describe the outcome, not the mechanism.

- ❌ `Extend post-sync cache invalidation to PO and PO-item field changes`
- ✅ `Refresh a PO's compliance review when the purchase order changes`

Keep any existing sequence prefix (`BE-5:`, `[BE]`) — it marks the ticket's place in its epic.
Update the title whenever the description is rewritten; a stale title undoes the rewrite.

### Length
Under ~50 lines rendered. Cut anything that does not change what gets built or tested.

## Quality bars — INVEST and SMART

These are **author-side checks, not ticket content.** They shape what you write and are the
last gate before applying the edit.

> **Never write them into the ticket.** No "INVEST" or "SMART" headings, no acronym, no
> letter-by-letter checklist, no "Valuable: yes" lines, no self-assessment section. A reader
> should only see a ticket that happens to be well-formed. If you want to report the check,
> report it in chat to the user — never in the description.

### INVEST — the story as a whole

| | Check | Fix when it fails |
|---|---|---|
| **I**ndependent | Can this ship without another unfinished ticket landing first? | Name the dependency in one Requirement bullet, or split the coupled part out. |
| **N**egotiable | Does it state the needed behavior, leaving room for how? | Cut the design detail — that is what the "no code" rules already enforce. |
| **V**aluable | Does the Problem statement name a real user and a real gain? | Rewrite the `so that …` clause until it names an outcome, not a task. |
| **E**stimable | Is the scope knowable — no unbounded "handle all cases"? | Enumerate the cases (that is what the data table is for) or ask the user. |
| **S**mall | One coherent behavior change, fitting a sprint? | Propose a split to the user; **do not split silently.** |
| **T**estable | Could QA verify every AC without reading code? | Restate the THEN as something observable. |

Two failures dominate: **Valuable** (the ticket describes a code change, not a gain — the
rewrite this skill exists for) and **Small** (an epic-sized rewrite hiding in a Story).

### SMART — each acceptance criterion

| | Check |
|---|---|
| **S**pecific | Exactly one behavior, with concrete preconditions. No "and also", no "etc.". |
| **M**easurable | The THEN has a verifiable outcome — a state, a count, a visible value. Not "works correctly", not "is up to date". |
| **A**chievable | Verifiable with the data and surfaces the ticket actually delivers; no dependency on something out of scope. |
| **R**elevant | Traces to a Requirement bullet. An AC that maps to nothing is scope creep — drop it or add the missing bullet. |
| **T**ime-bound | The WHEN names a definite trigger and the THEN a definite end state — the moment the criterion is settled. (Not a calendar date; deadlines belong in the sprint, not the AC.) |

Cross-check both directions: every Requirement bullet reaches at least one AC, and every AC
traces back to a bullet.

## Workflow

1. **Read the target.** For an existing ticket, fetch it *and* its parent epic for context.
   For a new ticket, gather the intent; ask the user the product term for the thing being
   changed if the code term is the only one available.
2. **Confirm scope before rewriting** when the source material is ambiguous — especially
   *which* changes should trigger the behavior. One clarifying question here prevents a
   rewrite that silently drops or invents scope.
3. **Draft** the three sections.
4. **Self-check against INVEST and SMART before applying** — run the two tables above over
   the draft and fix what fails. Two outcomes escalate to the user instead of being silently
   absorbed: a story that fails **Small** (propose the split, don't perform it) and one that
   fails **Estimable** because the case list is genuinely unknown (ask).
5. **Apply** via `editJiraIssue` (description + summary together, or note the summary
   separately if the user only asked for the body).
6. **Report the diff, not the ticket.** Show a compact before/after table of what changed and
   why — the user already knows the content; they need to see the judgment calls. Mention an
   INVEST/SMART fix here only when it changed the scope or split an AC; a clean check needs
   no commentary.
7. **Flag deliberate omissions.** If source material was dropped (a field group, a data
   source, a case), say so explicitly and name the risk of the gap having no ticket. Do not
   silently narrow scope, and do not invent scope the author's own artifacts contradict.

## Atlassian MCP notes

- Jira → `mcp__atlassian__*`. Confluence → `mcp__atlassian-docs__*`. The wrong server 403s.
- `cloudId` accepts the site URL (`inspectorio.atlassian.net`) and the response echoes the
  real UUID — use the UUID for follow-up calls in the same session.
- Pass `responseContentFormat: "markdown"` on reads and `contentFormat: "markdown"` on
  `editJiraIssue`. Without it you are handling raw ADF JSON for no benefit.
- `editJiraIssue` **replaces** the whole description. Fetch it first; never edit blind.
- Fetch `parent` on a Story to get the epic — it usually supplies the user-facing framing the
  Story is missing.
