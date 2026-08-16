# Review response workflow

## 1. Find the worktree

The pull request's head branch is the key. Ask git rather than reconstructing the
path from the branch name — the implementer may have added a suffix to avoid a
collision:

```bash
git -C /Users/lexuancuong/CUONG/SWC worktree list
```

Work inside the worktree holding that branch. If none does — a merged sibling's
cleanup may have reclaimed it — create one from the branch and do not touch the
main checkout:

```bash
git -C /Users/lexuancuong/CUONG/SWC worktree add \
  /Users/lexuancuong/CUONG/SWC-worktrees/<slug> "<head-branch>"
```

The main checkout may be dirty. Never stash, reset, clean, or otherwise alter it.

## 2. Sync with what the reviewer read

```bash
git fetch origin
git status
git log --oneline origin/<head-branch>..HEAD
git log --oneline HEAD..origin/<head-branch>
```

If the remote branch has commits you do not have, take them before changing
anything — someone may have pushed a fix already, and duplicating it produces a
confusing diff. If the two have diverged, stop and report it rather than
resolving it with a force-push.

Re-read the diff the reviewer commented on:

```bash
git diff origin/<base-branch>...HEAD
```

## 3. Work through the feedback

For each item, in the order it appears:

1. Read the code it points at, at the line it points at.
2. Decide fix, answer, or push back.
3. For a fix: change the code, then add or update the test that would have caught
   the defect. Run that test alone first and watch it fail against the old
   behaviour where practical — a test that passes before the fix is not a test of
   the fix.
4. Keep each fix a small, coherent commit. One commit per reviewer concern is
   easier to re-review than one commit for the round.

An **outdated** thread points at code that has since moved. The concern usually
still applies to wherever the code went — check before deciding it is stale, and
say which is the case in the reply.

## 4. Verify

Run what the affected components require, not a guessed subset:

- Backend: the focused tests, the relevant suite, Ruff lint and format check,
  Pyright where configured, and `makemigrations --check` if models changed.
- Frontend: focused unit tests and lint. If the diff now touches frontend source,
  configuration, dependencies, generated types, or build inputs, run the
  production build — from the final source state, after the last fix.
- Cross-stack: request/response types, casing conversion, `Club-ID` behaviour,
  permissions, error semantics, and kVND units.
- OpenSpec: `openspec validate "<change>" --strict` if the artifacts changed.

## 5. Push

```bash
git push origin "<head-branch>"
```

Plain push, no `--force`, no `--force-with-lease`. If the push is rejected,
something changed upstream: fetch, take those commits, re-verify, and push again.

## 6. Reply, then resolve

Reply on each thread with what you did, in one or two sentences. Name the commit
or the file and line where the fix landed, so the reviewer can jump straight to
it.

Resolve a thread only after replying, and only when you carried out the request
in full:

```bash
gh api graphql -f query='
  mutation($id: ID!) {
    resolveReviewThread(input: {threadId: $id}) { thread { isResolved } }
  }' -f id='<thread id>'
```

Leave unresolved: anything you pushed back on, anything you addressed only
partly, and anything where you are not certain the reviewer would agree the
request was met. An unresolved thread is a question waiting for a human; a
wrongly resolved one is a question that disappeared.

Finally, post one summary comment on the pull request: what changed, what you
resolved, and what you left open and why. That comment is the reviewer's entry
point when they come back to it.
