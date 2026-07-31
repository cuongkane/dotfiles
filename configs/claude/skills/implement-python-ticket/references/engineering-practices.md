# Engineering practices (Phase 3 — Code)

Distilled from the `backend-development` skill (code-quality, mindset, security, debugging),
adapted to Python. These are the standards the code you write for the ticket should meet. They
also feed the Phase 5 self-review checklist.

## Before writing code: think in systems

The plan (Phase 2) should already reflect this, but keep it in mind while coding:

- **Decompose:** understand the requirement → identify constraints → separate concerns
  (routing/DTO vs business logic vs data access) → define the interfaces between them.
- **Blast radius:** what else calls this? What breaks if it fails? Is it backward compatible?
- **Trade-offs:** optimize for maintainability by default; optimize a hot path only when the
  ticket is about performance. Core business logic deserves both.

## Layered separation of concerns

Keep the three layers distinct — it is what makes the code testable (Phase 4) without a real DB:

```
Presentation  → routers / controllers / DTOs / serializers   (thin: parse, validate, delegate)
Business      → services / use-cases / domain logic          (the part you unit-test hardest)
Data access   → repositories / ORM / query layer             (mock this in unit tests)
```

Business logic must not reach into the framework or the DB directly — inject the dependency so a
test can pass a fake. This is the practical form of **Dependency Inversion**: depend on an
abstraction (a repository/interface), not a concrete DB client.

## SOLID, applied pragmatically

- **Single Responsibility** — one reason to change per module/class/function. If a function
  "validates *and* persists *and* notifies", split it.
- **Open/Closed** — when you find an `if type == 'a' … elif type == 'b' …` that will keep
  growing, prefer a strategy/dispatch map over editing the conditional each time.
- **Liskov** — a subclass must honor the base contract (no `raise NotImplementedError` for a
  method the base promises).
- **Interface Segregation** — don't force callers to depend on methods they don't use.
- **Dependency Inversion** — inject collaborators (DB, HTTP client, clock) so they're swappable
  and mockable.
- **Explicit calls over boolean side-effect flags.** Don't add a `do_x=True`
  parameter that makes a function conditionally fire a side-effect — call the
  side-effect explicitly at each call site. It keeps the function single-purpose
  and the control flow readable at the call site.

Apply these to *solve a real problem in the diff*, not as a checklist to inflate the change.
YAGNI/KISS win ties: the smallest clear solution beats a pattern-heavy one.

## Clean code

- **Names say intent.** `calculate_area_in_meters(width_in, height_in)` over `d(a, b)`.
  **Spell out domain and service names in full**, using the wording the ticket and the team
  use — `AgentHubClient`, not `AgentClient`, when the service is "Agent Hub". A shortened name
  collides with the generic term it truncates, and the ambiguity spreads into class names,
  settings keys, env vars and log lines, making the rename expensive later. When the full name
  has a genuinely narrower sub-part (the *agent* hosted *by* the hub), keep both names distinct
  rather than reusing one for both.
- **Small functions**, ideally < ~20 lines, one level of abstraction each. Extract helpers.
- **No magic numbers/strings** — name them as constants (`MINIMUM_AGE = 18`).
  Put a named constant in the **most specific module that owns it** — if only one
  module consumes it, define it there, not in a shared/`*_const` module. Promote
  to a shared module only when a second consumer actually appears.
  And never **hardcode a shared constant's value** in a layer that can't import
  the constant (e.g. duplicating the string `'is_integration'` in a model because
  "importing it would pull in Django"). If a lower layer needs the literal, that's
  a signal the value should be **stamped by the layer that owns the constant**
  (import it and set it there), not copied down and defended with a
  "must stay in sync" comment.
- **Prefer a validated typed model over ad-hoc dicts for structured payloads.**
  For a dict that crosses a boundary (a logging `extra`, an event/message body,
  an API envelope), define a `pydantic` model / dataclass and have the caller
  build it and dump it (`model_dump()`), rather than assembling a bare dict at
  the call site. Invariant fields get defaults on the model, so callers can't
  drift. This validates types once and documents the shape.
  Keep the model a **pure data container** — fields, validation, and invariant
  defaults only. Formatting/mapping logic (turning the validated data into some
  output shape) belongs on the *consumer* that produces the output, not as a
  method on the model.
- **DRY in production code** — extract shared validation/helpers. (Note: the opposite applies to
  tests — see `testing-standards.md` guideline #5; duplication there aids readability.)
- **Reuse existing helpers over hand-rolled code.** Before writing inline logic — especially
  nested dict access — search for an existing util. For safe nested lookups prefer the project
  helper (e.g. `dict_get(product, 'coreProduct', 'primaryProductId')`) over chained
  `product.get('coreProduct', {}).get('primaryProductId')`. Grep for a helper first; hand-rolling
  a util that already exists is a common review nit.
  Reuse a shared util **as-is** — do not modify a `common/`/shared utility to fit
  one caller's need (it changes behavior for every other caller); adapt at your
  call site instead (e.g. guard `None` before calling, rather than broadening the
  util's `except`).
- **Comments explain *why*, not *what*.** The code already says what. This cuts both ways:
  - **Owed a comment:** any value a reader cannot derive from the line itself — a protocol
    header, a magic timeout, a cache directive, a deliberate deviation from a convention. State
    the consequence of removing it ("without this, nginx buffers the stream and delivers it all
    at once"), not the mechanism.
  - **Not owed one:** a comment whose claim the reader can't act on, or that narrates the call
    below it. If you can't finish the sentence "this matters because…", delete it.
- **Readable > clever.**

## Find where this kind of thing already lives

Before creating a new module, locate the existing instances of the *same kind of thing* and put
yours beside them. Outbound service clients, serializers, Celery tasks, permissions and factories
usually already have one canonical home; a new app-local `services/` package that duplicates that
home is a review comment waiting to happen.

- Search by kind, not by feature: `find . -name '*_client.py'`, `ls */tasks.py`,
  `find . -type d -name serializers`. One sibling is a precedent; three is a convention.
- Put it there **even when yours differs technically.** If your module can't reuse the shared
  plumbing (a shared session helper with a hardcoded timeout, say), the location convention still
  applies — document the deviation in a docstring rather than relocating the file.
- Deviate only with a stated reason, and expect to defend it in review.

## Python idioms

- **Guard with truthiness when "empty or missing" is the intent:** `if not primary_product_id:`
  rather than `if primary_product_id == '' or primary_product_id is None:`. It's the idiom
  reviewers expect and reads cleaner.
- **Caveat:** use `if x is None:` specifically when `0`, `0.0`, `''`, or `[]` are *valid* values
  you must distinguish from missing — truthiness would wrongly reject them.
- **Don't guard against states the contract rules out.** Before adding `or []` / `or {}` /
  `if x is None`, confirm the value can actually be null/absent — check the model field
  (`null=`/`default=`), the type hint (`Optional`?), or the caller. A guard on a
  `null=False`-with-default field or a non-`Optional` return is **dead code that hides a real
  violation** rather than handling a real case. Guard at true boundaries (external input,
  `null=True` column, optional params); trust values a layer above guarantees, and let a
  contract violation fail loudly.
- **Let the model drop unknown input; don't hand-filter.** pydantic v2 defaults to
  `extra='ignore'`, so `Model.model_validate(some_dict)` already discards keys that aren't
  fields. Don't write `{k: v for k, v in kwargs.items() if k in Model.model_fields}` before
  constructing — pass the dict straight in. (Use `extra='forbid'` only when an unexpected key
  should be a hard error.)

## Error handling (don't swallow failures)

- Never `except Exception: pass` or log-and-return-None silently. Either handle it meaningfully
  or let it propagate.
- Raise **specific, typed exceptions** (`UserNotFoundError`) over bare `Exception`; preserve the
  cause (`raise DomainError(...) from err`).
- Validate inputs at the boundary; fail fast with a clear message and the right status code.
- "Mishandling of exceptional conditions" is an OWASP 2025 entry — don't leak stack traces or
  internal details in responses.

### Secondary side-effects are the exception (best-effort)

The "never swallow" rule above is about the operation's *primary* logic. A
**secondary side-effect** — audit logging, event/Kafka emission, analytics —
must never break the primary operation. For those:

- Wrap the **entire** emission — payload building *and* attribute access, not
  just the network call. A field that is `None`/missing on an unexpected input
  must not bubble an `AttributeError` into the caller.
- Catch broadly, `log.exception(...)`, and continue.

The failure mode this prevents: a test with a minimal fixture (or a real edge
input) raises while *constructing* the log payload, and the exception escapes
because only the send was wrapped. Verify by reasoning: "if every attribute I
read here were absent, does the primary operation still succeed?"

## Security (relevant to most tickets)

- **Injection:** always use parameterized queries / the ORM's safe API — never f-string SQL.
  Validate/allow-list external input.
- **Access control:** enforce authorization on the backend, deny-by-default; never trust the
  client. Log authz failures.
- **Secrets/crypto:** no secrets in code or logs; use the platform's secret store; `secrets`/
  `os.urandom` for tokens, not `random`.
- **Dependencies:** if you add one, prefer an already-vetted one; note it for `pip-audit`.

## Edge cases to consider (and cover with tests)

Empty collections · `None`/missing fields · boundary values (0, max, negative) · duplicate/
idempotent requests · concurrent access/race conditions · dependency failure/timeout ·
malformed/malicious input · backward compatibility with existing data.

Each edge case you decide is in-scope becomes a named test in Phase 4.

## Observability

- Use the project's **structured logging** (e.g. `structlog`) with context, not bare `print`.
- Log at the right level; include identifiers (ids, not PII) so failures are traceable.

## Debugging discipline (if the ticket is a bug fix)

1. **Reproduce first** — a failing test that reproduces the bug is the ideal repro; write it
   before the fix so the fix is proven.
2. Read the logs/stack trace; form a hypothesis; test it. Avoid random changes.
3. Fix the root cause, not the symptom. Keep the repro test as a regression guard.

## Diff hygiene

- Change only what the ticket needs. Spotted an unrelated improvement? Note it as a follow-up
  ticket instead of expanding this diff.
- No dead code, debug prints, commented-out blocks, or unrelated formatting churn.
- Match the surrounding module's style, imports, and idioms.
- **When two forms are both defensible, count before choosing.** For repo-wide stylistic choices
  — f-string vs lazy `%s` logging, `Optional[X]` vs `X | None`, quote style, import grouping —
  grep both forms across the repo and follow the majority, even if you'd argue for the other on
  general principle. "Best practice" loses to "what this codebase does"; a lone divergence reads
  as carelessness to a reviewer.
