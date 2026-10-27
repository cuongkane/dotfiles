---
name: create-jira-bug
description: Write a Jira Bug ticket that a Product Owner and QA can understand without reading code. Produces the Inspectorio bug format — Feature → Steps to reproduce → Actual behavior → Expected behavior → Root cause → Proposed solution — one ticket per independent defect, then creates it in the ID2 project via the Atlassian MCP with the required fields set. Use when asked to "create a bug ticket", "log this as a bug", "file a Jira bug for this issue", or after an investigation that found one or more defects. For user stories / feature work use create-jira-ticket instead.
version: 1.0.0
---

# Create a Jira Bug Ticket

Turn a confirmed defect into a ticket a **PO can prioritise and QA can reproduce** —
described as behavior the user observes, not as the code that produces it.

## Core principle

**A bug ticket states what the user sees, what they should see, and why — in product terms.**

If a reader who has never opened the repo cannot reproduce the bug from the ticket alone, it
is not done. Function names, file paths, table/column names and stack traces stay out of the
ticket; the developer finds them from the root cause sentence.

## Before writing — evidence first

Only file what is proven. For each defect, know:

| Need | Source |
|---|---|
| A real example (org, record ids, timestamps) | The user's report, production queries |
| The actual behavior | Screenshots, activity/audit log, DB state |
| The root cause | Code path **confirmed by data** (query output, logs) |

- Root cause **confirmed** → state it plainly.
- Root cause **only suspected** → either confirm it first (give the user a query / log search),
  or write it as "Suspected: …". Never present a guess as a cause.
- Unknown parts (e.g. external API semantics) → say "unknown" in Proposed solution; do not invent.

**One ticket per independent defect.** Two causes that happen to share an example are two
tickets — each must be fixable and testable on its own. Mention the shared example in both.

## The format

Jira renders markdown — `**bold**` headers, `*` bullets, numbered steps.

```markdown
**Feature**

<1–2 sentences: what the feature is supposed to do, in product vocabulary. No defect here.>

**Steps to reproduce**

1. <Precondition / setup the tester needs (org config, data state).>
2. <User action, in UI terms: screen → action.>
3. <Where to look.>

Example: <org>, <record name> `<id>`, <date / time UTC>.

**Actual behavior**

* <What the user sees — observable, specific.>
* <Secondary consequence (status stuck, data missing).>

**Expected behavior**

* <What the user should see instead — observable, specific.>

**Root cause**

<1–3 sentences in plain language: what goes wrong and why the user sees the symptom.
Name the scope if the same defect affects other cases.>

**Proposed solution**

* <Behavior change that fixes it — "what", not "how".>
* <Known gaps / unknowns that block a full fix.>
* <Open question for PO, if any (e.g. backfill of already-affected records).>
```

## Rules

### Voice
- Product vocabulary: "Lab Test activity", "Integration Center → Audit Logs", "Filed / Not Filed",
  "Automation" — never `CpscImportLog`, `status=FAILED`, `_apply_supported_fixes`.
- Each section concise and sharp: bullets, not paragraphs. Whole ticket under ~40 lines.
- The heading is **Proposed solution**, never "Solution" — it is not final until the PO agrees.

### Steps to reproduce
- Lead with the preconditions (configuration and data state) — most "cannot reproduce" comes
  from a missing precondition.
- UI path and wait time where relevant ("wait ~2 minutes — the result check runs every minute").
- Always end with a real **Example** line (ids in backticks, times in UTC).

### Actual vs Expected
- Mirror each other: every actual bullet has a matching expected bullet.
- Observable only: a status, a missing entry, a visible value. Not "the payload is wrong".

### Root cause
- Explain the mechanism in plain words ("the correction is written to a part of the
  submission CPSC does not read"), not the code location.
- State the blast radius: which other cases/flows share the defect.

### Title
- `[<Feature area>] <user-visible symptom>` — match the prefix recent bugs in that area use
  (search first; e.g. `[CPSC eFiling]`).
- ❌ `Fix _apply_supported_fixes writing to top-level manufacturer`
- ✅ `[CPSC eFiling] Automatic retry resends the same data, so "already exists" rejections always end in Fail`

## Workflow

1. **Collect evidence** (see above). If the root cause is not yet confirmed, hand the user the
   query / log search to confirm it before filing.
2. **Find conventions**: JQL `project = ID2 AND issuetype = Bug AND text ~ "<area>" ORDER BY created DESC`
   — copy the title prefix, component and labels used by recent bugs in the same area.
3. **Draft** each ticket and show it to the user if they have not already approved the content.
4. **Create** with `createJiraIssue` (see fields below). Create independent tickets in parallel.
5. **Report**: a table of key → title, the fields you chose, and anything left for the user
   (epic, links between the tickets, open questions).

## Atlassian MCP notes (ID2 project)

- Jira → `mcp__atlassian__*`. `cloudId` accepts `inspectorio.atlassian.net`; reuse the echoed UUID.
- Use `contentFormat: "markdown"` for the description.
- **Required fields on ID2 Bug** — creation fails without them:

| Field | Value |
|---|---|
| `issueTypeName` | `Bug` |
| `customfield_11151` (Environment Name, multi-checkbox) | `[{"id": "10718"}]` Production · `10716` Staging · `10717` Preproduction · `11261` Feature Branch — pick where the bug was observed |
| `components` | at least one, e.g. `[{"id": "12138"}]` (Lab Test) · `12135` Lab Test Form — copy from similar bugs |

- Labels: `BE` / `FE` by the side that needs fixing.
- Do not set a parent epic that is Closed; leave it for the user and say so.
- Creating a ticket is outward-facing — only create when the user asked for the ticket.
