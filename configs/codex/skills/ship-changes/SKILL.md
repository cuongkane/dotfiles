---
name: ship-changes
description: Commit and push repository changes safely. Use when the user asks to ship, commit, push, create a commit, or publish current changes, including Parcel Perform repositories with Jira-prefixed commit messages.
---

# Ship Changes

Do not commit secrets, credentials, `.env` files, or unrelated user changes. Never force-push, use `--no-verify`, or amend unless explicitly requested.

## Workflow

1. Run `git status --short` and stop if there are no changes.
2. Run `git log --oneline -5` to match recent commit style.
3. Summarize changed files and decide what belongs in the commit. Prefer staging specific files over `git add -A`.
4. Detect whether the repo is a Parcel Perform project from `basename $(git rev-parse --show-toplevel)`.
5. For repos whose name starts with `pp_`, require a Jira ID in brackets at the start of the commit message. Extract it from the branch name when possible.
6. If on `main` or `master`, warn before pushing directly and ask for confirmation.
7. Commit with a concise message. For PP repos, use `[JIRA-ID] Description`.
8. Push to the current branch. If no upstream exists, push with `git push -u origin <branch>`.
9. Report the short commit hash, pushed branch, and number of files changed.

## PP branch and commit conventions

- Feature branch for dev/master: `jira-issue-id-explanation`.
- Feature branch for squad env: `jira-issue-id-squad_name-explanation`.
- Hotfix branch: `hotfix-jira-issue-id-explanation`.
- Commit message: `[JIRA-ID] Description of change`.

If a PP repo branch does not contain a recognizable Jira ID, ask the user for it before committing.
