Commit all current changes and push to the remote git repository.

The arguments are: "$ARGUMENTS" (optional: commit message or flags).

## Workflow

### 1. Pre-flight checks

- Run `git status` to check for changes (staged, unstaged, untracked).
- If there are no changes at all, inform the user and stop.
- Run `git log --oneline -5` to see recent commit style.

### 2. Stage changes

- Show a summary of all changes (files added, modified, deleted).
- Stage all relevant changes with `git add` (prefer specific files over `git add -A`; never stage `.env`, credentials, or secrets).

### 3. Craft the commit message

Write a concise conventional commit message summarizing the changes.

If `$ARGUMENTS` is provided and looks like a commit message, use it.

### 4. Commit

Create the commit. Append the co-author trailer:
```
Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

Use a HEREDOC to pass the message:
```bash
git commit -m "$(cat <<'EOF'
Your commit message

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

### 5. Push

- Determine the current branch with `git branch --show-current`.
- Check if the branch has an upstream with `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`.
- If no upstream exists, push with `-u`: `git push -u origin <branch>`.
- If upstream exists, push with `git push`.

### 6. Summary

Show a short summary:
```
Committed: <short hash> <commit message>
Pushed to: origin/<branch>
Files changed: <count>
```

## Important rules

- Never commit files that contain secrets (`.env`, credentials, API keys, tokens).
- If a pre-commit hook fails, fix the issue and retry with a NEW commit (never `--amend` unless explicitly asked).
- Never use `--force` push unless the user explicitly requests it.
- Never use `--no-verify` to skip hooks.
- If on `main` or `master`, warn the user before pushing directly.
