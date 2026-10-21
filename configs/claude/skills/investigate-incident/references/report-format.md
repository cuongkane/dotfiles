# Report format

Three sections. Short enough to read without scrolling. Lead with the verdict.

```
Hi <name>,

I finished the investigation on <INC-ID>. This is <a form mis-configuration / a code defect /
a data issue>, not <the thing people assumed>.

**Problem**

On <record identifier the reader can look up>, <endpoint> returns <actual>, while <the value>
is returned under <where it actually is>.

<One sentence on why the UI and the API disagree, if they do.>

**Root cause**

<Where the decision is actually made — configuration, contract, or code — in user-visible terms.>

<The rule that governs it: "X is stored by <type>, not by <name>". One line.>

<What that means for this record. Then: the data isn't lost / the data was never stored.>

**Proposal**

<The single change, and what closing the INC depends on.>

<What the change does not cover — existing records, backfill, follow-up ticket.>
```

## Rules

- **Name user-visible things.** "The stakeholder panel named Brand/Retailer", not
  `LabTestCustomOrg.form_custom_id`. Identifiers and file paths go in the thread, not the message.
- **State the governing rule once**, as a general sentence, then apply it. It is what the reader
  carries away and reuses on the next incident.
- **"The data isn't lost — it's stored as X"** is worth its own line whenever true. It downgrades the
  perceived severity accurately and immediately.
- **No repetition between Problem and Root cause.** If a sentence explains *why*, it belongs in Root
  cause; Problem states only what is observed.
- **One recommendation, not a menu.** Alternatives go in a follow-up if asked.
- **Separate what you could not verify** — keep it out of the message, hand it to the requester as
  "have this ready if he pushes back": scope counts, and whether the proposed fix is even possible
  in the UI.
- Attach the screenshot or query output that carries the proof; do not paste raw JSON inline.

## When you were wrong earlier in the investigation

Correct it in one sentence and continue. No re-litigating, no tally. If an earlier hypothesis was
shared with others, say plainly that it does not apply to this record and why the data ruled it out.
