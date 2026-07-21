# Workflow — step by step

Five phases, two hard gates. The gates are the point of this skill: they stop a plausible-but-wrong
implementation before it is written.

---

## Phase 1 — Clarify requirements (from the ticket only — do NOT read the code yet)

**Goal:** surface vagueness and uncertainty in the ticket *as early as possible*, before any code
exploration. This is deliberate: reading the code first makes you infer what the ticket
"probably means" and quietly resolve ambiguities that the author should resolve. Judge the
ticket on its own terms first.

1. Resolve the ticket ID from the user's input (accept `ABC-123` or a full Jira URL).
2. Fetch the ticket using your Atlassian MCP tools (Jira routing per your global CLAUDE.md).
   Read the description, acceptance criteria, comments, linked issues, and attachments. If the
   fetch fails, stop and tell the user — do not proceed from a guessed ticket.
3. **Do not open the codebase in this phase.** No file search, no grep, no repo reading. Work
   only from the ticket and its linked context. (Codebase grounding happens in Phase 2, after the
   requirements are confirmed.)
4. Assess the ticket for **clarity/completeness** and write a **restatement** back to the user:
   - **Goal** — one or two sentences, in your own words.
   - **Acceptance criteria** — bullet list, each independently checkable. If the ticket has none,
     say so — that itself is an open question.
   - **In scope / out of scope** — explicit, as you understand it from the ticket.
   - **Assumptions** — anything you'd otherwise silently assume; make it visible so it can be
     corrected.
   - **Open questions** — numbered, and this is the core deliverable of this phase. Flag every
     ambiguity or gap the *ticket text* leaves open, e.g.:
     - Vague/undefined terms ("improve", "handle properly", "etc.") — ask for the concrete rule.
     - Missing expected behavior on edge cases (empty, error, concurrent, boundary).
     - Undefined data shapes / API contracts / status codes / error messages.
     - Backward-compatibility and migration expectations.
     - Non-functional requirements (performance, permissions, auditing) not stated.
     - Unstated dependencies on other tickets/teams/services.
   - **Readiness call** — state plainly whether the ticket is *ready to implement as written*, or
     *needs clarification first*, and why.

### GATE A — requirements confirmed
State clearly: *"Please confirm this understanding / answer the open questions before I plan.
I have not looked at the code yet."*
**Stop and wait.** Only proceed once the user confirms or resolves the questions. If they add
scope, update the restatement and re-confirm. Do not start Phase 2 (which is when you read the
code) until the requirements are settled.

---

## Phase 2 — Implementation plan

**Goal:** an approved design and an explicit test list.

**Now** explore the codebase (this is the first phase that reads code): find where the change
lives, the existing patterns/layers to follow, and anything that changes the approach. If the
code reveals a *new* ambiguity that contradicts the confirmed requirements, surface it and
return to GATE A rather than resolving it silently.

Then produce a concise plan (prefer the `concisely-propose-solution` style — objective, numbered,
no filler):

- **Approach** — one sentence, then the sequence of changes.
- **Files to change / add** — path per bullet, with what changes in each.
- **Data / API / schema changes** — migrations, contracts, backward-compat notes.
- **Edge cases & error handling** — what happens on bad input, empty, failure of a dependency.
- **Test plan** — the explicit list of test cases you will write, **one behavior per case**,
  named in the `test_should[nt]_<expected_behavior>_when_<scenario>` style. This list is the
  coverage contract.
- **Risks / out of scope** — anything deferred, anything that needs a follow-up ticket.

### GATE B — plan approved
State clearly: *"Approve this plan and I'll implement it."* **Stop and wait** for explicit
approval ("approved", "go ahead", "lgtm"). Do not write code — not even a branch — before this.
If the user requests changes, revise and re-present.

---

## Phase 3 — Code

1. Confirm a clean working tree. If there are unrelated local changes, ask before
   proceeding.
2. Create the branch per `references/git-conventions.md`:
   `feature|fix|chore/<ticket-id>/<subject>`.
3. Implement the **smallest** change that satisfies the approved plan, following
   `references/engineering-practices.md`: keep the presentation/business/data-access layers
   separate and inject dependencies so business logic is unit-testable without a real DB; apply
   SOLID pragmatically (YAGNI/KISS win ties); use clear names and named constants; handle errors
   with specific typed exceptions (never swallow); use parameterized queries and backend-side
   authorization; and consciously handle the edge cases you'll test in Phase 4.
4. Match the surrounding code's style, naming, and idioms. No opportunistic refactors outside the
   plan — if you spot one, note it for a follow-up ticket instead.
5. Keep the diff reviewable: cohesive, no dead code, no debug prints, no commented-out blocks.

---

## Phase 4 — Tests

Follow `references/testing-standards.md`. In short:

1. Write a test per case from the approved test plan — one behavior each, AAA layout,
   self-sufficient, deterministic. Mock external/out-of-process dependencies; never hit a real
   DB or network in a unit test.
2. Run the test suite for the touched area and make it green.
3. **Confirm completeness by reasoning through the diff, not by running a coverage tool.** Local
   diff-coverage tooling is impractical here, so instead walk the change and check that:
   - every new/changed **code path** has a test — happy path, each `if`/`else` branch, each
     `except`/error path, each early return;
   - every **acceptance criterion** from the ticket has a test that demonstrates it;
   - the in-scope **edge cases** identified in Phases 1–3 each have a test.
   Present this as a short **diff → test map** (each changed function/branch → the test(s) that
   cover it) so a reviewer can see nothing was missed.
4. If a path is deliberately left untested (e.g. trivial passthrough, or something in the
   "what not to unit test" list), name it and justify it — don't leave it silently uncovered.
5. Be honest about method: state that completeness was verified by reasoning over the diff, not
   measured by a tool. Never report a coverage percentage you did not actually measure.

---

## Phase 5 — Code review (before the MR)

**Goal:** catch defects and edge cases while the code is still local and easy to change.

1. **Discover the code-review tool** and use the first that exists:
   - a repo-local skill at `./.claude/skills/code-review/` (invoke it),
   - a global `code-review` skill, or a `code-reviewer` / `code-review` **agent** (dispatch it),
   - otherwise the built-in `/code-review`.
   If none is available, do a structured self-review against the diff using the
   `references/engineering-practices.md` standards (layered separation & injectability,
   SOLID/YAGNI/KISS/DRY, naming & constants, error handling, security, edge cases, diff hygiene)
   and say that no dedicated reviewer was found.
2. **Scout edge cases first** (empty/nil/boundary inputs, failure of a mocked dependency,
   concurrency, backward-compat) and confirm the test plan covers them — add tests if not.
3. **Run the review on the branch diff:** give the reviewer what changed, the plan, the ticket
   context, and the diff — the branch's changes relative to the merge-base of the target branch
   through `HEAD`.
4. **Act on findings:** fix **Critical** and **Important** before Phase 6. For anything you
   consciously skip, verify the claim technically and state why (no performative agreement).
5. Re-run the tests after fixes (green), and re-check the diff → test map still holds — any code
   added during review needs its own test.

Only proceed to the MR once Critical/Important findings are resolved.

---

## Phase 6 — Draft MR

Follow `references/git-conventions.md`. In short:

1. Stage and commit with a conventional subject: `[<TICKET>] <Imperative subject ≤50 chars>`,
   body explaining what & why. Add `Co-authored-by:` trailers if pairing.
2. Push the branch.
3. Open the MR as **Draft** with the GitLab CLI, following `references/git-conventions.md` for
   the title/description format and target branch. The MR **must** open in Draft status — never
   mark it ready automatically.
4. Ensure the ticket is linked in title/description. Optionally transition the Jira ticket or add
   a comment with the MR link **only if the user asks** — do not change ticket state silently.
5. Report the **MR URL** and a short summary of what was implemented and tested, including the
   diff → test map.

---

## Gate-handling protocol (applies to A and B)

- Present the artifact, then ask one clear question and **stop your turn**.
- Treat silence as not-approved. Do not proceed on assumption.
- If the user answers only part of the open questions, ask again on the rest before advancing.
- Approval for one phase is not approval for the next.
