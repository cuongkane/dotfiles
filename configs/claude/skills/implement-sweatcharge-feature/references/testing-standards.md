# Testing standards

Build a diff-to-test map before delivery:

| Changed behavior or path | Test | Result |
|---|---|---|
| Happy path | Named test | Pass/fail |
| Each conditional branch | Named test | Pass/fail |
| Each expected error | Named test | Pass/fail |
| Each OpenSpec scenario | Named test | Pass/fail |

## Rules

- Test behavior, not private implementation details.
- Follow the closest existing test style and helpers.
- Keep one primary behavior per test with clear arrange, act, and assert stages.
- Make tests deterministic and self-contained; freeze time and isolate external services when needed.
- Cover authorization, club isolation, validation, boundary values, and failure paths when relevant.
- For migrations, test or verify data movement and reversibility proportional to risk.
- For Angular, cover component/service state transitions and API success/error behavior.
- For cross-stack changes, test matching contracts on both sides where practical.
- Do not claim a coverage percentage unless a tool actually measured it.
- If a path cannot reasonably be tested, document the path, reason, and residual risk in the PR.

Run focused tests during implementation and the broadest relevant stable suite before delivery.
Treat a test that never observes the changed behavior as missing coverage.
