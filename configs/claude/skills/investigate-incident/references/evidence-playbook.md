# Evidence playbook

Run these yourself with the read-only recipe in `database-access.md` (10s statement timeout,
identity-anchored filters). Table names in `sight-be` are Django defaults (`<app>_<modelname>`, lowercased, no
underscores in the model part) unless the model sets `db_table` — check before asserting a name, and
tell the user a wrong guess will surface as an obvious "relation does not exist".

## Query 1 — the record and its provenance (always first)

Answer two things at once: is the disputed column empty, and **which entry point created this row**.

```sql
SELECT
    lt.id, lt.uid, lt.uuid, lt.status,
    lt.integration_api    AS created_via_integration_api,   -- UI vs integration API
    lt.created_at, lt.created_by_id,
    lt.<disputed_fk>_id,
    o.name                AS <disputed_fk>_org_name
FROM <table> lt
LEFT JOIN <join tables to resolve the fk to a human name> o ON …
WHERE lt.uuid = '<uuid from the ticket>';
```

Prefer the **UUID** from the ticket over a display number — a "Lab Test ID: 6014" may be a case
number, a PK, or a UID, and guessing wrong wastes a round trip.

A provenance flag that contradicts your hypothesis ends that hypothesis. Say so at once.

## Query 2 — the neighbouring relations, with discriminators

Show what *is* stored where the data actually went, including the columns that distinguish rows
from each other (`tier`, type, `form_custom_id`, position). `UNION ALL` sibling relations so they
can be compared in one output.

```sql
SELECT 'supplier' AS relation, s.id, s.tier, o.name AS org_name,
       lo.custom_id AS local_org_custom_id, co.form_custom_id
FROM lab_test_labtestsupplier s
JOIN lab_test_labtestcustomorg co ON co.id = s.lab_test_custom_org_id
JOIN accounts_org o               ON o.id = co.org_id
LEFT JOIN accounts_org lo         ON lo.id = co.local_org_id
WHERE s.lab_test_id = <id>
UNION ALL
SELECT 'factory', f.id, f.tier, o.name, lo.custom_id, co.form_custom_id
FROM lab_test_labtestfactory f
… ;
```

A NULL where siblings have values (e.g. one org with no `local_org_custom_id`) is a fingerprint of a
different input route — note it, but do not over-read it until something else corroborates.

## Query 3 — the configuration the record actually used

Query the **version the record points at** (the template *history*), never the current template.

```sql
SELECT lt.id, ft.custom_id AS form_custom_id, ft.name AS form_name,
       lt.lab_test_form_template_history_id,
       jsonb_pretty(
           jsonb_path_query_array(h.form::jsonb,
               '$.** ? (@.dataName == "<section dataName>")')
       ) AS section
FROM lab_test_labtest lt
JOIN lab_test_labtestformtemplatehistory h ON h.id = lt.lab_test_form_template_history_id
JOIN lab_test_labtestformtemplate ft       ON ft.id = h.lab_test_form_template_id
WHERE lt.id = <id>;
```

`$.**` matches at every nesting level, so components often appear **twice** in the output. That is a
duplicate match, not duplicate configuration — check before reporting it as one.

Parse the JSON rather than eyeballing a padded psql table: strip the column, `json.loads`, then walk
it printing only `(type, tier, label, isActive, customId)` per component. Grep on a wrapped table
column loses the structure and misleads.

## Query 4 — who owns the configuration

Cheap, and it decides who is asked to fix it.

```sql
SELECT ft.id, ft.custom_id, ft.name, ft.org_id, o.name AS owner_org
FROM lab_test_labtestformtemplate ft
JOIN accounts_org o ON o.id = ft.org_id
WHERE ft.id = <id>;
```

## Query 5 — scope

Offer it unprompted; the PO's next question is always "how many?".

```sql
SELECT lt.integration_api,
       COUNT(*)                                          AS total,
       COUNT(*) FILTER (WHERE lt.<disputed_fk>_id IS NULL) AS affected
FROM lab_test_labtest lt
WHERE lt.book_to_org_id = (SELECT book_to_org_id FROM lab_test_labtest WHERE id = <id>)
  AND lt.created_at >= NOW() - INTERVAL '90 days'
GROUP BY lt.integration_api;
```

Derive the org id from the record. An org id quoted in a ticket is often a **portal URL id**, not
the `accounts_org` PK — if a count comes back with zero rows, suspect that before suspecting the data.

## Query 6 — the linking ID (the proof step)

Confirm one identifier present in both the configuration and the stored row.

```sql
SELECT s.tier, o.name AS org_name, co.form_custom_id
FROM lab_test_labtestsupplier s
JOIN lab_test_labtestcustomorg co ON co.id = s.lab_test_custom_org_id
JOIN accounts_org o               ON o.id = co.org_id
WHERE s.lab_test_id = <id>
ORDER BY s.tier;
```

Match each `form_custom_id` against the `customId` of the configuration component. A match turns a
consistent narrative into a proven chain. A NULL means the system fell back to positional matching —
same outcome here, but worth flagging as fragile.

## Layer map — where `lab_test` stakeholder-shaped data lives

| Concern | Location |
|---|---|
| Integration read | `lab_test/serializers/integration/lab_test_integration_detail_serializer.py` |
| Integration create contract | `lab_test/serializers/integration/lab_test_create_serializer.py` |
| UI create/update | `lab_test/serializers/lab_test_serializer.py` |
| UI read | `lab_test/serializers/lab_test_detail_serializer.py` |
| Routing constants (types, tiers) | `lab_test/config/lab_test_form_template.py` |
| Storage | `LabTest.<fk>` columns; `LabTestSupplier`/`LabTestFactory` rows (`lab_test/models/lab_test_associations.py`) |
| FE payload routing | `sight-fe/src/app/modules/lab-test/shared/models/test-upsert.models.ts` |
| FE panel rendering / read-back | `sight-fe/src/app/modules/lab-test/create-edit-form/stakeholders/`, `…/stakeholder-data/` |
| FE config enums | `sight-fe/src/app/configuration/lab-test-forms/shared/lab-test-forms.constants.ts` |

Verify each path still exists before citing it; these move.
