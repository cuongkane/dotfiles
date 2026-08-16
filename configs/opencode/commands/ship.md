---
description: Commit current changes and push to the remote repository
---

Commit all current changes and push to the remote git repository.

The arguments are: "$ARGUMENTS" (optional: commit message or flags).

## Workflow

### 1. Pre-flight checks

- Run `git status` to check for changes (staged, unstaged, untracked).
- If there are no changes at all, inform the user and stop.
- Run `git log --oneline -5` to see recent commit style.

### 2. Stage changes

- Show a summary of all changes.
- Stage all relevant changes with `git add`; prefer specific files over `git add -A`.
- Never stage `.env`, credentials, API keys, tokens, or unrelated user changes.

### 3. Craft the commit message

Write a concise conventional commit message summarizing the changes.

If `$ARGUMENTS` is provided and looks like a commit message, use it.

### 4. Commit

Create the commit. Do not amend unless explicitly asked.

Use a HEREDOC for multi-line messages:

```bash
git commit -m "$(cat <<'EOF'
Your commit message
EOF
)"
```

### 5. Push

- Determine the current branch with `git branch --show-current`.
- Check if the branch has an upstream with `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`.
- If no upstream exists, push with `git push -u origin <branch>`.
- If upstream exists, push with `git push`.

### 6. Summary

Show a short summary:

```text
Committed: <short hash> <commit message>
Pushed to: origin/<branch>
Files changed: <count>
```

The `/ship` command does not create or rename branches. It only commits and pushes on the current branch.

## Important rules

- Never commit files that contain secrets.
- If a pre-commit hook fails, fix the issue and retry with a new commit.
- Never use `--force` push unless the user explicitly requests it.
- Never use `--no-verify` to skip hooks.
- If on `main` or `master`, warn the user before pushing directly.
