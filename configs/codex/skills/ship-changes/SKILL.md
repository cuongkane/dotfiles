---
name: ship-changes
description: Commit and push repository changes safely. Use when the user asks to ship, commit, push, create a commit, or publish current changes.
---

# Ship Changes

Do not commit secrets, credentials, `.env` files, or unrelated user changes. Never force-push, use `--no-verify`, or amend unless explicitly requested.

## Workflow

1. Run `git status --short` and stop if there are no changes.
2. Run `git log --oneline -5` to match recent commit style.
3. Summarize changed files and decide what belongs in the commit. Prefer staging specific files over `git add -A`.
4. If on `main` or `master`, warn before pushing directly and ask for confirmation.
5. Commit with a concise conventional commit message.
6. Push to the current branch. If no upstream exists, push with `git push -u origin <branch>`.
7. Report the short commit hash, pushed branch, and number of files changed.
