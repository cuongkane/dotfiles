---
name: respond-sweatcharge-review
description: Address review feedback on an open SweatCharge pull request — fix what the reviewer identified, add the missing tests, reply to each thread, and push. Works in the existing feature worktree under /Users/lexuancuong/CUONG/SWC, adds commits rather than rewriting them, and resolves only the threads it actually fixed. Use when a pull request has unresolved review threads, a changes-requested review, or new reviewer comments.
version: 1.0.0
---

# Respond to SweatCharge Review

Take a pull request that has been reviewed, and leave it in a state where the
reviewer's next look is their last.

## Operating contract

- Work in the existing worktree for the pull request's head branch, under
  `/Users/lexuancuong/CUONG/SWC`. Never in the main checkout.
- **Add commits. Never force-push, rebase, or amend.** The reviewer has read the
  existing commits; rewriting them destroys the comparison they will use to check
  your response, and detaches every review thread from its code.
- Reply to every item. Silence on a thread reads as having missed it.
- Resolve only threads you fixed in full.
- Verify to the same bar as the original implementation before pushing.
- The request to use this skill authorizes pushing this feature branch to the
  verified SweatCharge `origin`. It does not authorize merging, marking anything
  ready, closing the pull request, or touching another branch.

## Workflow

Follow [references/review-workflow.md](references/review-workflow.md).

1. Locate the worktree for the head branch, or create one if it was reclaimed.
2. Fetch, and take any commits on the remote branch you do not have.
3. Triage each item into fix, answer, or push back.
4. Implement the fixes, with the tests that would have caught each defect.
5. Verify — the affected suites, lint, type checks, and the frontend production
   build if any frontend source or build input changed.
6. Commit and push.
7. Reply to each thread, and resolve the ones you carried out in full.

Read these when entering the corresponding phase, from the sibling
`implement-sweatcharge-feature` skill so the two agents hold one standard:

- `../implement-sweatcharge-feature/references/engineering-practices.md` before fixing.
- `../implement-sweatcharge-feature/references/testing-standards.md` before writing tests.

If those files are not present, apply the conventions the repository itself
demonstrates. Repository-local instructions — root `CLAUDE.md`, `AGENTS.md`,
component instructions, Feature RFC guidance — override this skill.

## Triage

**Fix** when the comment identifies a real defect, a missing test, a violated
convention, or an unhandled case. Change the code *and* add the test that would
have caught it. A fix with no test invites the same comment on the next pull
request.

**Answer** when it is a question. Reply with the answer and the evidence, and
resolve the thread.

**Push back** when the comment is wrong or asks for something that conflicts with
an OpenSpec requirement or a repository instruction. Say so directly, cite the
evidence, and **leave the thread unresolved** — that is the reviewer's decision
to make, not yours. Pushing back is a legitimate outcome; silently complying with
a comment that would break something is not.

## Scope discipline

Fix what was raised. Do not take the opportunity to refactor adjacent code,
rename things, or address issues nobody mentioned — every unrequested change
enlarges the diff the reviewer must re-read, which is the cost this whole step
exists to reduce. If you notice a genuine problem outside the feedback, mention
it in the reply and leave it.

If the requested change invalidates the OpenSpec artifacts, update the proposal,
design, delta specs, or tasks to match before delivering, and revalidate
strictly. Never let shipped behaviour diverge from the archived specification.

## Completion requirements

Do not report success unless:

- every item in the feedback has been fixed, answered, or explicitly pushed back
  on, with a reply on its thread;
- each fix has a test that observes the corrected behaviour;
- the affected checks pass, and the frontend production build succeeded from the
  **final** source state if frontend source or build inputs changed;
- OpenSpec artifacts still validate strictly, if the change touched them;
- the branch is pushed and the worktree holds no unrelated changes; and
- every thread you resolved was one you actually carried out in full.

If you could not make the branch green, say so. A pushed branch that fails its
own tests is worse than an honest report of what broke.
