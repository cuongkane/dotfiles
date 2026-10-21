# Reproduction tests

The goal is not a failing test. It is a **characterization test**: construct the reported stored
state, hit the real endpoint, and assert what it returns today. It passes, and that is the finding —
the read path reports storage faithfully, so the defect is upstream.

Only invert it into a failing test once the team has agreed what the correct behavior should be.

## Where they go (`sight-be`)

Add to the existing e2e/view test case for that endpoint — the fixtures (orgs, form templates, JWT
auth) already exist there and are expensive to rebuild. A new standalone file usually means
duplicating a 150-line `setUpClass`.

```
lab_test/tests/e2e/test_lab_test_integration_view.py   # integration API
lab_test/tests/views/…                                 # UI-facing APIs
```

## The two tests worth writing

**1. Stored-state → read.** Build the exact DB shape from the incident (the disputed FK left NULL,
the value present in the relation it actually landed in), GET the endpoint, assert the reported
response. This exonerates the read path.

**2. Create → retrieve.** Only if the create contract is also suspect. POST through the API, assert
the record was stored as claimed, then GET and assert the response shape the customer reported.
This proves an entry point can produce the state — but *not* that it produced **this** record.
Say so explicitly; provenance comes from the DB (`integration_api` and friends), not from a test.

## Conventions that bite

- Comment each test with the INC id and the behavior it pins, so a later reader knows it asserts
  current — possibly wrong — behavior deliberately.
- Reuse the class's `base_request_data`; override only what the scenario needs.
- Strip payload extras that reach external services — attachments trigger FMS signed-URL calls and
  will fail with a DNS error on retrieve. `additional_data_fields` must reference keys that exist in
  the fixture org or the POST returns 400.
- When a POST returns an unexpected status, temporarily assert with the body
  (`assertEqual(r.status_code, 201, r.json())`) to see the validation error, then remove it.
- Run through Docker: `make test <path-or-nodeid>`. Then `flake8 <file>`.
- Single quotes, trailing commas, 120 cols. No `# Arrange/Act/Assert` comments.

## Reading a failure

`make test` output is long; the real assertion is easy to miss. Pull the failing line and the
traceback's *last project-owned frame* — that tells you whether the failure is your scenario or
incidental fixture noise (external HTTP, missing dark feature, unseeded reference data).
