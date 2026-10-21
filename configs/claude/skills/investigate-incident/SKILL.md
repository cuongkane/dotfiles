---
name: investigate-incident
description: Investigate a production incident (Jira INC / Slack escalation) about wrong or missing API data in the Inspectorio stack, then deliver a concise Problem → Root cause → Proposal report for the PO. Evidence-driven — reproduce on the API, get ground truth from the DB, trace the write path that created the record, check configuration, and only then conclude. Use for "debug INC-…", "investigate this incident", a Slack incident link, "why does this API return null/wrong data", or "is this a bug or a data issue?".
version: 1.0.0
---

# Investigate Incident

Take an incident report about wrong API data from symptom to a **verified** root cause and a short
report a PO can act on.

## Core principle

**Most "API returns wrong data" incidents are not read-path bugs.** The read path usually mirrors
storage faithfully. The defect is upstream — in what was written, by which entry point, under which
configuration. So the investigation moves *backwards* along the data's life:

```
   read path        →  does the API mirror the DB?          (usually yes: exonerate it)
   stored state     →  what is actually in the DB?          (ground truth — ask the user to run SQL)
   write path       →  which entry point created this row?  (UI? integration API? import? clone?)
   configuration    →  what did that entry point obey?      (form template, rules, feature flags)
   linkage          →  prove config → data with a shared ID (not a plausible story: an ID match)
```

Stop only when a fact chain runs end to end. A plausible mechanism that you have not tied to *this
record* is a hypothesis, and must be labelled as one.

## Non-negotiables

- **Never present an unverified mechanism as the cause.** Say "proven", "inferred", or "unknown".
- **Kill your own hypothesis out loud** the moment data contradicts it. Say plainly that it was
  wrong, then move on — do not quietly reshape it to survive.
- **Prior triage (bot summaries, earlier comments, the reporter's own diagnosis) is a lead, not
  evidence.** Re-derive every claim you intend to repeat.
- **Query the DB yourself, read-only, with a statement timeout** — see `references/database-access.md`.
  Never invent, assume, or "expect" a result you have not seen returned.
- **UI-visible ≠ stored.** A screen showing a value proves the screen can find it, not which field
  holds it. The two often disagree, and that gap is frequently the whole incident.
- **A label is not a type.** Display names, headings, and translations never travel with the data.
  Logic keys off types, enums, and IDs.

## Phases

### 1. Read the report — extract identifiers, not narrative

From the Jira INC and/or Slack thread, pull:

- the **exact endpoint** and the field(s) said to be wrong;
- the **record identifier** (prefer UUID over a display number — a "Lab Test ID" in a ticket may be
  a case number, a PK, or a UID);
- **expected vs actual**, verbatim;
- **environment**, and whether it reproduced elsewhere ("did not replicate in Demo" is a strong
  signal for a data- or config-specific condition, not a code regression);
- any **screenshots** — read them, they often carry the configuration that explains everything.

State the symptom back in one sentence before touching code.

### 2. Trace the read path — exonerate or convict it

Find the serializer/view for that endpoint and read what each disputed field is sourced from. Ask
only: *does this faithfully report stored state?* If yes, say so and stop looking here.

### 3. Reproduce on the API

Write a **characterization test** that constructs the reported stored state and asserts the API's
current response. It passes — that is the point: it pins the behavior and proves the read path is
not inventing anything. See `references/reproduction-tests.md`.

If the create path is also suspect, add a second test that goes create → retrieve through the API.

### 4. Get ground truth from the DB

Run the queries in `references/evidence-playbook.md`, using the connection recipe in
`references/database-access.md`. Answer, at minimum:

- is the disputed column actually empty/wrong in storage?
- **which entry point created this record?** (`integration_api`, `created_by`, `created_at`,
  `duplicated_from`, source flags) — this single answer usually eliminates half the hypotheses;
- what *is* stored in the neighbouring relations, with their discriminators (tier, type, custom ids)?

Read the output carefully before theorising. If it contradicts your hypothesis, say so immediately.

Paste real output into your findings. If the tunnel is down, ask the user to start it rather than
reasoning from an assumed answer.

### 5. Trace the write path that actually created it

Only now, and only for the entry point the data named. Different entry points have different
contracts — a rule in the integration serializer is irrelevant if the row came from the UI.

### 6. Check configuration

Templates, rule builders, feature flags, and org-level settings routinely decide where data lands.
Query the exact configuration version the record used (e.g. the form template *history* the record
points at, not the current template). Look for **label/type mismatches**: a field named one thing
and typed another.

### 7. Cross-verify in the other repo

For a UI-originated record, confirm in `sight-fe` how the payload is built — which field it reads
to route the value. Frontend routing logic is the missing half of most write-path stories.

### 8. Close the loop with a linking ID

Find one identifier that appears in **both** the configuration and the stored row (a component
UUID, a rule id, a template custom id) and confirm the match. This converts "consistent story" into
"proven". Never skip it when such an ID exists.

### 9. Report

Use `references/report-format.md`. Three sections, short. Lead with whether it is a bug.

## Delivering the report

The PO decides; you supply facts and one recommendation. Include:

- **what is proven vs inferred** — and what you could not check;
- **scope** — is this one record or a pattern? Offer the counting query even if not asked;
- **whether the proposed fix is actually possible** — if you have not verified the customer can make
  the change in the UI, say so rather than promising it.

Write for someone who has not read the code. Name user-visible things, not classes and columns.
Keep it to what fits on one screen; put the SQL and code references below the fold or in a thread.
