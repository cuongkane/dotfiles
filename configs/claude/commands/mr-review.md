---
description: Review an Inspectorio GitLab MR (sight-fe or sight-be) against its Jira ACs, with cross-repo and breaking-change verification
allowed-tools: Bash(glab:*), Bash(git:*), Bash(grep:*), Bash(sed:*), Bash(awk:*), Bash(cat:*), Bash(wc:*), Bash(find:*), Bash(python3:*), Read, Grep, Glob, mcp__atlassian__getJiraIssue
---

Review the Inspectorio merge request: "$ARGUMENTS" (MR number or URL; optionally `--post` to publish findings).
If empty, use the MR for the current branch.

**This review is evidence-based.** Every claim you make must cite `file:line` or the command that proves it.
Never restate the MR description as if it were fact — it is a claim to be verified (MR descriptions here are often
AI-authored and have contained provably wrong statements). Do not spawn subagents unless the user asks.

## Workspace

Repos are siblings under `~/INSPECTORIO/`, each independently cloned:
`sight-fe` (Angular 21) · `sight-be` (Django, project `quality_control`) · `agent` · `document-validator`.
A Lab Test / QRM change usually spans more than one. `cd` into the right repo before grepping.

---

## Step 0 — Gather, before forming any opinion

```bash
glab mr view <ID>                                   # description, labels, pipeline, source branch
glab mr diff <ID> --raw > <scratchpad>/mr<ID>.diff  # authoritative change set
git fetch -q origin <source-branch>
```

Split the diff for reading:
```bash
awk '/^diff --git/{p=($0 !~ /spec\.ts|test_.*\.py/)} p' <scratchpad>/mr<ID>.diff   # production code
awk '/^diff --git/{p=($0 ~  /spec\.ts|test_.*\.py/)} p' <scratchpad>/mr<ID>.diff   # tests
```

**Do not `git diff master...<branch>`.** The local `master` is routinely hundreds of commits stale, so the
merge-base makes an 8-file MR look like 400 files. `glab mr diff` is the change set; read full files at branch
state with `git show "origin/<branch>:<path>"`.

**zsh gotcha:** `$B:src/app/...` triggers zsh parameter modifiers and mangles the ref.
Always brace it: `git show "${B}:src/app/..."`.

## Step 1 — Get the real acceptance criteria

Extract the ticket key from the branch or title (`[ID2-37000]`), then:

```
mcp__atlassian__getJiraIssue
  cloudId: inspectorio.atlassian.net
  fields: ["summary","description","status","labels","issuetype","parent"]
  responseContentFormat: markdown
```

- Record the **parent Epic** — general ACs (super properties, internal-user exclusion, empty values,
  environments) usually live there, not on the story.
- Note the `FE` / `BE` labels. A `BE` label with no backend change in the MR is a question to raise, not an
  assumption to make.
- If the ticket links a spec you cannot open, say so in Limitations. Do not infer its contents.

## Step 2 — Verify the description against the code

For each factual claim in the MR description, confirm or refute it. Real misses caught this way:
a claim that another caller "also receives the extra field" when it never passes the parameter; a reviewer note
warning about an unguarded throw that the code already wraps in `try/catch`. Report stale or wrong description
bullets as housekeeping — they mislead the next reviewer.

## Step 3 — Breaking-change sweep

- **Signatures:** are new params optional? Find *every* caller — `git grep -n "<symbol>" "origin/<branch>" -- "src/**"`
  — and confirm each still compiles. Positional `undefined` placeholders at call sites are a smell (Step 6).
- **New DI:** is the injected service `providedIn: 'root'`? If not, every component that provides the consumer
  locally breaks, including specs.
- **Shared state / response shape:** if an API response gains a field that lands in a store, find every consumer
  of that slice. If the only reader is a spec, say so *and show the grep that proves it* — that is the finding.
- **Import cycles** when a service starts importing a sibling service.
- Enum and constant additions are additive; call them safe and move on.

## Step 4 — Cross-repo verification (highest-value step; do not skip)

**A frontend change that adds or alters an API parameter is unverified until you check `sight-be`** — and the
reverse for backend MRs.

1. Grep the other repo for the parameter in **both** casings (`extraFields` and `extra_fields`).
2. Trace it end to end: accepted → converted → does it change the serializer's field filtering, the queryset's
   prefetching, or the response body?
3. Confirm the *value* matches the AC's wording by reading the serializer field, not by assuming.
   (e.g. AC said "short name"; `lab_test_serializer.py:486` is `CharField(source='lab_test_type.short_name')` ✓.)
4. Check whether a degenerate input changes behaviour (empty config, null relation, legacy v1 path still reachable).
5. State the commit of the other repo you checked — local clones go stale.

For `sight-be` MRs, reverse it: a changed response field or new query param is unverified until you grep
`sight-fe` for the consumer.

## Step 5 — Pipeline triage

```bash
glab api --hostname gitlab.inspectorio.com "projects/<url-encoded-path>/merge_requests/<ID>/pipelines"
glab api --hostname gitlab.inspectorio.com "projects/<enc>/pipelines/<PIPELINE_ID>/jobs?per_page=100"
glab api --hostname gitlab.inspectorio.com "projects/<enc>/jobs/<JOB_ID>/trace" | sed 's/\x1b\[[0-9;]*m//g'
```

Use the **MR's** pipelines, not `glab ci status` — the branch can have a different, passing pipeline that hides a
failing MR pipeline.

Classify every failure before reporting it:
- `TerminationByKubelet`, `node was low on resource: memory`, runner disruption → **infrastructure, retry it**, not a code defect.
- `QUALITY GATE STATUS: FAILED` (SonarQube) → real blocker; note you cannot see which condition failed without dashboard access.
- Genuine assertion failures → quote them.

Repo test commands, for reproducing: `sight-fe` → `npm test -- --include <path> --watch=false`, `npm run test:vitest`.
`sight-be` → `pytest --reuse-db <path>`, `inv test` (enforces a 100% coverage gate), `flake8`.

## Step 6 — AC conformance table

One row per AC: ✅ / **Partial** / ❌ / **Unverified**, each with `file:line` evidence.
- Never mark ✅ without evidence you actually looked at.
- Anything depending on a document you could not read is **Unverified**, never ✅.
- When the implementation diverges from the ticket's wording, surface it as a **product question** with both
  readings — do not silently bless the implementation.

## Step 7 — Code smells pass

Recurring patterns in this codebase, highest-value first:

1. **DRY** — a map, label set, or constant duplicated instead of imported.
2. **Accidental totality** — `x === A ? 'A' : 'B'` over an enum that may gain a third member; silently mis-reports. Prefer an exhaustive `Record<Enum, T>` plus an explicit default.
3. **Loose types at a boundary** — `unknown[]` / `any` where callers pass concrete types; a later refactor then breaks an AC with no compile error and no failing test.
4. **Empty `catch {}`** — especially in analytics/telemetry whose entire purpose is data collection. Best-effort delivery is fine; best-effort observability is not. Require a log.
5. **Dead guards + specs that pin unreachable states** — if an earlier `throw` or a non-optional type already precludes the case, the guard is dead and the spec covering it is coverage theater. The spec is the worse half.
6. **Stringly-typed values** where a union or enum already exists.
7. **Optional-param creep** — `fn(a, b, undefined, {...})` at a call site; suggest an options object, but respect that extending an existing signature is the surgical choice.
8. **i18n** — never concatenate translated fragments; one full-phrase key per variant (see `sight-fe/CLAUDE.md`).
9. **Client-side gating presented as authorization** — must be independently enforced by the endpoint.
10. Then apply the extra patterns in `code-review-practices`.

Also honour the repo's own `CLAUDE.md`: standalone components mandatory, signals preferred, OnPush, modern
control flow, design tokens over hardcoded colours, 400-line file limit.

**Say explicitly when something looks like a smell but is correct** (e.g. a predicate that widens to
`boolean | number` because the declared model really is that union) — it stops the next reviewer re-raising it.

## Step 8 — Report

```
Verdict (one line)
1. Breaking changes      — or "none found", with the checks that prove it
2. Pipeline              — infra vs real, blockers
3. AC conformance table
4. Gaps worth raising    — ranked, each actionable
5. Code smells           — ranked; "worth fixing" vs "minor"
6. Limitations           — MANDATORY: what you could not verify and why
```

Separate the three categories strictly: a **breaking change**, an **AC gap**, and a **smell** are different
severities and must not be blended.

## Step 9 — Posting (only when the user asks)

Plain comment, **not** resolvable:
```bash
glab mr note <ID> -m "$(cat <scratchpad>/note.md)"
```

Resolvable **thread** (what reviewers usually want — the author can reply and tick it off):
```bash
glab api --hostname gitlab.inspectorio.com --method POST \
  "projects/<url-encoded-path>/merge_requests/<ID>/discussions" \
  -f body="$(cat <scratchpad>/note.md)"
```

- **`--hostname gitlab.inspectorio.com` is mandatory for writes.** Without it `glab api --method POST` fails with
  `Unauthenticated` even though GET calls on the same config succeed. This is a `glab` behaviour, not the `rtk` wrapper.
- Write long bodies to a scratchpad file first; pass with `$(cat file)`.
- Confirm success: the response must show `individual_note: false` and `resolvable: true`.
- **One thread per independent concern**, so each resolves separately. Bundle only when the user asks for a single note.
- Remove a mistaken note:
  `glab api --hostname gitlab.inspectorio.com --method DELETE ".../discussions/<discussion_id>/notes/<note_id>"`
- Address the author (or the AI copilot on `ai-to-resolve` MRs) with concrete instructions: the file, the change,
  the tests to add or invert, and any approach to avoid plus the reason.
- Never post anything without explicit instruction.
