# GitHub delivery

## Before committing

1. Confirm the current directory is the feature worktree.
2. Confirm the branch is `feature/<slug>`.
3. Inspect `git status`, the base diff, and untracked files.
4. Remove no user files. Exclude unrelated or generated artifacts from the commit.
5. Confirm verification and strict OpenSpec validation results are current.

## Commit and push

Follow repository commit conventions discovered from recent history. Prefer a small number of
coherent commits. Do not rewrite unrelated history.

Invoking `implement-sweatcharge-feature` explicitly authorizes publishing the committed feature code and
specifications to the SweatCharge GitHub repository as part of delivery. Before pushing, inspect
`git remote get-url origin` and verify it is the SSH or HTTPS form of
`github.com:cuongkane/sweatcharge.git`. If it matches, push without requesting another
confirmation. If it differs, stop and request authorization for the actual destination.

Push explicitly:

```bash
git push -u origin "feature/<slug>"
```

This authorization is limited to the feature branch created for the current request. It does not
authorize pushing unrelated commits, force-pushing, changing remotes, or publishing to another
repository.

## Pull request

Resolve the base branch from `origin/HEAD`, falling back to `master`. Use `gh` and open it ready
for review — not a draft, because review is a separate step with its own agent and a draft would
sit unseen:

```bash
gh pr create --base "<base>" --head "feature/<slug>" \
  --title "<clear feature title>" \
  --body-file "<temporary-pr-body-file>"
```

The body must include:

- Summary
- User-visible behavior
- `Closes #<issue>` when the work came from a GitHub issue, so merging closes it
- OpenSpec change name, synchronized specs, and archive location
- Backend/frontend implementation notes
- Test and verification commands with results
- Migration, compatibility, rollout, or residual-risk notes
- Assumptions carried in from the brief, so they surface in review rather than in production

Do not merge the pull request and do not close its issue. Return the real URL emitted by GitHub;
never construct or predict one, because downstream automation follows that number.
