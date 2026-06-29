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

### 2. Detect if this is a Parcel Perform project

Check if the repository name from `basename $(git rev-parse --show-toplevel)` starts with `pp_`.

If yes, this is a PP project: apply the PP Git naming convention below.
If no, use standard commit conventions.

### 3. Stage changes

- Show a summary of all changes.
- Stage all relevant changes with `git add`; prefer specific files over `git add -A`.
- Never stage `.env`, credentials, API keys, tokens, or unrelated user changes.

### 4. Craft the commit message

For PP projects, the commit message must include the Jira issue ID in brackets at the beginning:

```bash
git commit -m "[JIRA-123] Your message"
```

- Extract the Jira issue ID from the current branch name when possible.
- If the branch name does not contain a recognizable Jira issue ID, ask the user for it.
- If `$ARGUMENTS` is provided and looks like a commit message, use it, but still prepend the Jira ID for PP projects.

For non-PP projects, write a concise conventional commit message summarizing the changes.

### 5. Commit

Create the commit. Do not amend unless explicitly asked.

Use a HEREDOC for multi-line messages:

```bash
git commit -m "$(cat <<'EOF'
[JIRA-ID] Your commit message
EOF
)"
```

### 6. Push

- Determine the current branch with `git branch --show-current`.
- Check if the branch has an upstream with `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`.
- If no upstream exists, push with `git push -u origin <branch>`.
- If upstream exists, push with `git push`.

### 7. Summary

Show a short summary:

```text
Committed: <short hash> <commit message>
Pushed to: origin/<branch>
Files changed: <count>
```

## PP Git Naming Convention

When the repo name starts with `pp_`, follow these rules:

- Feature for dev/master: `jira-issue-id-explanation` (for example, `HEIMDALL-1804-add-webhook-retry`)
- Feature for squad env: `jira-issue-id-squad_name-explanation` (for example, `COD-123-cod-new-featureX`)
- Hotfix for production: `hotfix-jira-issue-id-explanation`
- Commit message format: `[JIRA-ID] Description of change`

The `/ship` command does not create or rename branches. It only commits and pushes on the current branch.

If on a PP project and the current branch is `master` or `main`, warn the user that they should be on a feature branch and ask for confirmation before proceeding.

## Important rules

- Never commit files that contain secrets.
- If a pre-commit hook fails, fix the issue and retry with a new commit.
- Never use `--force` push unless the user explicitly requests it.
- Never use `--no-verify` to skip hooks.
- If on `main` or `master`, warn the user before pushing directly.
