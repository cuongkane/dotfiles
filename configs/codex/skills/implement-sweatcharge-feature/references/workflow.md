# Workflow

## 1. Create the worktree first

Before inspecting feature code or invoking OpenSpec:

1. Confirm `/Users/lexuancuong/CUONG/SWC` is a git repository.
2. Derive a short kebab-case slug from the request.
3. Use branch `feature/<slug>`.
4. Use worktree `/Users/lexuancuong/CUONG/SWC-worktrees/<slug>`.
5. Check that neither branch nor path already exists. If either belongs to the same unfinished
   feature, reuse it only when clearly safe; otherwise derive a unique suffix.
6. Determine the base from the local `origin/HEAD`, falling back to `origin/master`, then local
   `master`. Do not fetch before worktree creation.
7. Run:

   ```bash
   git -C /Users/lexuancuong/CUONG/SWC worktree add \
     -b "feature/<slug>" \
     "/Users/lexuancuong/CUONG/SWC-worktrees/<slug>" \
     "<base-ref>"
   ```

Create the worktree with this explicit command rather than the harness worktree tool, so the path
and branch stay predictable and the phases below can address them directly.

The source checkout may be dirty. Never copy, stash, reset, clean, or otherwise alter its changes.
Verify the new worktree starts clean. From this point forward, operate only inside the worktree.

## 2. Explore

1. Read root instructions and the instructions for each potentially affected component.
2. Invoke the worktree's `openspec-explore` skill (`.codex/skills/openspec-explore`).
3. Inspect existing OpenSpec changes and main specs, affected code, tests, Feature RFCs, and git
   history.
4. Turn the rough request into:
   - problem and desired outcome;
   - observed current behavior;
   - proposed user-visible behavior;
   - likely backend/frontend boundaries;
   - constraints and edge cases;
   - facts, assumptions, and open questions.
5. Resolve ordinary unknowns from repository evidence. Pause only for material ambiguity.

Explore mode is read-only for application code. Proceed directly to proposal when the feature is
clear enough.

## 3. Propose

Invoke `openspec-propose` (`.codex/skills/openspec-propose`) with the explored brief and
derived change name. Follow the CLI-reported artifact graph and paths rather than assuming
locations.

Ensure proposal, design, delta specs, and tasks:

- cover both backend and frontend when the behavior crosses the API boundary;
- define API contracts, authorization, monetary units, validation, and failure behavior as needed;
- include explicit implementation, test, verification, and Feature RFC update tasks;
- distinguish facts from assumptions;
- remain narrow enough for one reviewable pull request.

Run `openspec status --change "<change>"` and strict validation before apply. Fix artifact errors.
No approval gate is required unless a material ambiguity remains.

## 4. Apply

Read [engineering-practices.md](engineering-practices.md) and
[testing-standards.md](testing-standards.md), then invoke `openspec-apply-change`
(`.codex/skills/openspec-apply-change`).

For each task:

1. Read the CLI-provided context files.
2. Inspect the local implementation pattern.
3. Implement the smallest cohesive change.
4. Add or update tests in the same task or immediately afterward.
5. Run focused checks.
6. Mark the task complete only after its code and tests are done.

If implementation invalidates the design, update the proposal/design/spec/tasks before continuing.
Never silently ship behavior that differs from the artifacts.

## 5. Verify

Map every changed behavior, branch, and error path to a test. Then run the checks required by the
affected components and their local instructions.

Typical checks include:

- Backend: focused Django tests, full relevant test suite, Ruff lint/format check, Pyright where
  configured, and `makemigrations --check` for model changes.
- Frontend: focused unit tests and lint. If the diff changes frontend source, configuration,
  dependencies, generated types, or build inputs, run the repository's production build; this is
  mandatory, not proportional or optional.
- Cross-stack: verify request/response types, casing conversion, `Club-ID` behavior, permissions,
  errors, and kVND semantics.
- OpenSpec: `openspec validate "<change>" --strict`.

Use repository commands, not guessed replacements. Fix failures caused by the branch. Clearly
separate unrelated environmental failures from code failures.

## 6. Review

Review the complete diff from the base branch using the available code-review skill or the
`/code-review` command, run from inside the worktree. Check:

- correctness against OpenSpec scenarios;
- regressions, edge cases, auth, tenancy, money, migrations, and compatibility;
- Python and TypeScript maintainability;
- test completeness and false-positive tests;
- accidental, generated, secret, or unrelated files.

Fix all critical and important findings, rerun affected checks, and re-review the resulting diff.
If review fixes touch frontend source or build inputs, rerun the production build after the final
fix. A build result from an earlier source state does not satisfy verification.

## 7. Sync specifications

Invoke `openspec-sync-specs` (`.codex/skills/openspec-sync-specs`) with the explicit
change name. Confirm the merge is idempotent and preserves unrelated requirements.

Also update any affected frontend Feature RFC required by `sweatcharge_fe/AGENTS.md` and its
current spec guide. Re-run strict OpenSpec validation before archiving.

## 8. Archive the OpenSpec change

After implementation, tests, review, Feature RFC updates, and spec sync are complete:

1. Confirm every task is checked off.
2. Run `openspec status --change "<change>"` and resolve incomplete artifacts or tasks.
3. Run `openspec validate "<change>" --strict`.
4. Archive non-interactively with the explicit change name:

   ```bash
   openspec archive "<change>" --yes
   ```

Use the CLI directly here. The repository's `openspec-archive-change` skill prompts the user to
pick a change and to confirm warnings, which conflicts with this skill's autonomous contract.

Do not use `--skip-specs` or `--no-validate`. The prior sync makes the archive's spec update
idempotent and gives the CLI a final consistency check.

Verify that the active change no longer appears in `openspec list --json`, locate its archived
directory, and run:

```bash
openspec validate --specs --strict --no-interactive
```

If archiving or post-archive validation fails, fix the artifacts or main specs before delivery.
Do not open the pull request while the completed change remains unarchived.
Before delivery, confirm the recorded frontend production build corresponds to the current
`HEAD`/working-tree source state. Run it again if any frontend code or build input changed since
the last successful build.

## 9. Deliver

Read [github-delivery.md](github-delivery.md). Inspect the final status and diff, commit coherent
changes, push the feature branch, and open a GitHub pull request ready for review.

The request to use this skill already authorizes pushing the current feature branch to the
verified SweatCharge GitHub `origin` and opening its PR; do not introduce a separate
confirmation gate. If authentication is unavailable, request only the required credential access.
Never pretend a PR exists, and never report a URL you did not receive from GitHub.

Do not merge it, and do not close the issue it references. `Closes #<issue>` in the body lets the
merge do that.
