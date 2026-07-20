# Testing standards

Source of truth: Inspectorio **Unit Testing Best Practices**
(https://inspectorio.atlassian.net/wiki/spaces/ED/pages/54494273) — encoded below.
Reconcile with https://www.cuongkane.com/blog/write_valuable_tests when accessible; that post
frames the same ideas as four pillars (protection against regressions, resistance to refactoring,
fast feedback, maintainability). Guidelines #6 and #7 below are the "resistance to refactoring"
pillar.

## Goals

- **Cover all new and refactored code.** The team standard is 100% coverage of new/changed code.
  Here you achieve it by *reasoning*, not by running a coverage tool (local diff-coverage is
  impractical): every new/changed code path and every acceptance criterion gets a test. See
  "Coverage by reasoning" below.
- Full suite runtime trends toward **≤ 10 minutes** — keep unit tests fast.
- Unit tests are for guarding behavior during refactoring, **not primarily for finding bugs**.

## The 8 guidelines

1. **Know what you're testing.** One thing per test. A failing simple test points straight at the
   cause. **No `if` statements in tests** — branching means the test does more than one thing.
2. **Self-sufficient.** Isolated: no dependence on environment settings, registry values, or
   databases. No dependence on other tests or on execution order. Running it 1,000 times gives the
   same result. Initialize and clean any global state between runs (`setUp`/`tearDown`), or avoid
   global state entirely.
3. **Deterministic.** A test passes all the time or fails until fixed — a sometimes-passing test is
   equivalent to no test. Avoid random *characteristics* of input (Faker/Factory generating a
   random datatype — number vs string vs nil vs empty). Fixed input like `"Mary"` is fine; letting
   the datatype itself vary is not.
4. **Naming conventions.** The test method and class names must make a failure self-explanatory.
   Name a test after both the **expected behavior** and the **scenario** that triggers it, in the
   form `test_should[nt]_<expected_behavior>_when_<scenario>`, e.g.
   `test_should_send_email_when_alerts_are_muted`,
   `test_shouldnt_send_email_when_alerts_are_muted`,
   `test_should_send_okay_email_when_all_alerts_are_good`. Reading the name alone should tell you
   what broke and under which condition. Do not rely on test execution order for meaning — the
   runner may reorder.
5. **Do repeat yourself.** Unlike production code, some duplication in tests is fine and preferred
   over cleverness that hides what a test does. Changing 4–5 similar tests beats one unreadable
   non-duplicated test. You *may* extract object creation to factory methods and complex checks to
   custom assertions — as long as readability does not suffer.
6. **Test results, not implementations.** A test should fail only on an actual error or a
   requirement change — never merely because internals were refactored while behavior stayed the
   same.
7. **Avoid over-specification.** Don't lock the exact process flow. E.g. don't assert a method was
   called exactly three times without asserting the inputs. Don't use "strict" mocks that throw on
   any unexpected call. Over-precise tests are fragile.
   Concretely: don't assert an entire returned dict/object for equality — assert
   the few fields that encode the behavior. A full-object assertion breaks on any
   incidental field (timestamps, added keys) and reads as "regressing every line"
   rather than protecting a behavior.
8. **Use an isolation (mocking) framework.** Use `unittest.mock` (`patch`) rather than hand-rolled
   mocks. `patch` replaces the target named in the decorator/context and returns the configured
   value during the test.

## What NOT to unit test

- Constructors / properties that just return variables (test only if they validate).
- Configuration: constants, read-only fields, configs, enums.
- Facades that only wrap another framework/library.
- Container service registrations.
- Exception *messages*.
- Plain models/entities with no validation or conditional construction.
- Private methods directly (test them through the public surface).
- Complex SQL (>3 joins/grouping) — cover with a manual/system test against a real DB instead.
- Complex multi-threading — cover with integration tests.
- Methods that only call another public method.

## The AAA pattern

Structure every test as **Arrange → Act → Assert** (a.k.a. **Given / When / Then**):

- **Arrange** — build objects and input data; set up mocks/fakes.
- **Act** — invoke the unit under test once.
- **Assert** — verify the observable result/behavior.

**Exactly one AAA cycle per test.** Do not stack multiple Act/Assert blocks in one function to
avoid re-doing Arrange — split into separate tests instead.

## sight-be conventions (Sight – Web – Backend)

The team's stated anti-patterns to avoid: tests hitting real DB/network, tests that are really
integration tests, one function doing many jobs with many expectations.

**Do:** unittest-style classes with Factories + mocks, one behavior per function.

```python
class AggregateItemsTest(unittest.TestCase):
    def setUp(self):
        # init shared data for the class
        ...

    def test_should_return_items_when_single_item_given(self):
        # Arrange
        item_data = [PurchaseOrderItemData(items=items, assortments=assortments, solid=solid)]
        item_dict = PurchaseOrderItemVersion2DictFactory(item_id="item_001", ...)
        # ...set up mocked dependencies and fake data...

        # Act
        actual = PurchaseOrderItemVersion2Service.aggregate_items(item_data)

        # Assert
        self.assertIn("items", actual)

    def test_should_drop_assortments_when_items_conflict(self):
        # Arrange
        item_data = [PurchaseOrderItemData(), PurchaseOrderItemData()]
        # Act
        actual = PurchaseOrderItemVersion2Service.aggregate_items(item_data)
        # Assert
        self.assertEqual([], actual["assortments"])

    def tearDown(self):
        # clear per-test state
        ...
```

**Don't:** one test with multiple Arrange/Act/Assert blocks, real `GetItemFromDataBase()` calls,
or real `self.client.post(...)` API calls inside a unit test.

### Fixtures & mocking specifics

- **Test data:** prefer Factories (e.g. `*Factory` classes) or the `mixer` library over
  hand-built dicts, so data generation isn't hand-maintained. Keep generated values
  deterministic in *datatype* (see guideline #3).
- **Mocking:** `from unittest.mock import patch`. Patch where the name is *looked up*, not where
  it's defined. Assert on inputs, not just call counts (guideline #7).

## Coverage by reasoning — procedure

We do **not** run a diff-coverage tool here (running it locally is impractical). Instead, achieve
full coverage of new/changed code by reasoning over the diff and mapping each change to a test.

1. Run the touched-area tests and make them green:
   ```
   pytest <path/to/tests>
   ```
   If the full test runner won't start in your environment (native-lib/DB setup
   issues), you can still run DB-free, pure-logic tests directly with
   `python -m unittest <dotted.module.path>` — this skips DB/plugin setup and
   still exercises validation/branch logic. To keep that possible, keep pure-logic
   modules free of heavy app-graph imports (importing a module that pulls the ORM
   makes its unit tests un-runnable without the DB stack).
2. Walk the diff and confirm each of these has a test:
   - every new/changed **code path** — happy path, each `if`/`else` branch, each `except`/error
     path, each early return;
   - every **acceptance criterion** from the ticket;
   - every in-scope **edge case** from Phases 1–3 (empty, `None`, boundary, duplicate, dependency
     failure, …).
3. Produce a short **diff → test map** so a reviewer can verify nothing was missed, e.g.:
   ```
   service.aggregate_items() — merge branch      → test_should_return_items_when_single_item_given
   service.aggregate_items() — conflict branch    → test_should_drop_assortments_when_items_conflict
   service.aggregate_items() — empty input guard  → test_should_return_default_when_input_empty
   AC "duplicates are dropped"                     → test_shouldnt_keep_duplicates_when_items_repeat
   ```
4. If a path is deliberately left untested (trivial passthrough, or something in "what not to
   unit test"), name it and justify it — don't leave it silently uncovered.
5. **Be honest about method:** state that completeness was verified by reasoning over the diff,
   not measured by a tool. Never report a coverage percentage you did not actually measure.

## Quick checklist before opening the MR

- [ ] One behavior per test; no `if` in tests.
- [ ] AAA, exactly one cycle each; clear `test_should[nt]_<expected_behavior>_when_<scenario>` names.
- [ ] No real DB/network/env dependency; deterministic; order-independent.
- [ ] Tests results/behavior, not internals; no over-strict mocks.
- [ ] Every new/changed path + acceptance criterion + in-scope edge case has a test.
- [ ] Diff → test map produced; any deliberately-untested path named and justified.
- [ ] Full touched-area suite is green and fast.
