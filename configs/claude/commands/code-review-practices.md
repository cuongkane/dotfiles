# Team Code Review Practices

Additional patterns to flag during code reviews, learned from past MR feedback.

1. **Extract reusable utils** — If domain-agnostic logic (e.g., Pydantic introspection) is inlined in service/action code, suggest extracting into a shared utility with tests.
2. **Missing unit tests** — Flag new public functions/actions without dedicated unit tests, even if integration tests exist.
3. **Name complex conditions** — Flag compound boolean expressions not assigned to descriptive variables (e.g., `has_all_required = _REQUIRED <= actual`).
