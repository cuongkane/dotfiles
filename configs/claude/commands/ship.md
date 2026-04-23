Commit all current changes and push to the remote git repository.

The arguments are: "$ARGUMENTS" (optional: commit message or flags).

## Workflow

### 1. Pre-flight checks

- Run `git status` to check for changes (staged, unstaged, untracked).
- If there are no changes at all, inform the user and stop.
- Run `git log --oneline -5` to see recent commit style.

### 2. Detect if this is a Parcel Perform project

Check if the **repository name** (from `basename $(git rev-parse --show-toplevel)`) starts with `pp_`.

If yes, this is a **PP project** — apply the PP Git naming convention (see section below).
If no, use standard commit conventions.

### 3. Stage changes

- Show a summary of all changes (files added, modified, deleted).
- Stage all relevant changes with `git add` (prefer specific files over `git add -A`; never stage `.env`, credentials, or secrets).

### 4. Craft the commit message

**For PP projects**, the commit message MUST include the Jira issue ID in brackets:
```
git commit -m "Your message [JIRA-123]"
```
- Extract the Jira issue ID from the **current branch name** (the branch should start with or contain a Jira issue ID like `HEIMDALL-1804`, `COD-123`, etc.).
- If the branch name does not contain a recognizable Jira issue ID, ask the user for it.

**For non-PP projects**, write a concise conventional commit message summarizing the changes.

If `$ARGUMENTS` is provided and looks like a commit message, use it (but still append the Jira ID for PP projects).

### 5. Commit

Create the commit. Append the co-author trailer:
```
Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

Use a HEREDOC to pass the message:
```bash
git commit -m "$(cat <<'EOF'
Your commit message [JIRA-ID]

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

### 6. Push

- Determine the current branch with `git branch --show-current`.
- Check if the branch has an upstream with `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`.
- If no upstream exists, push with `-u`: `git push -u origin <branch>`.
- If upstream exists, push with `git push`.

### 7. Summary

Show a short summary:
```
Committed: <short hash> <commit message>
Pushed to: origin/<branch>
Files changed: <count>
```

## PP Git Naming Convention (Parcel Perform projects)

When the repo name starts with `pp_`, follow these rules:

### Branch naming
- **Feature for dev/master**: `jira-issue-id-explanation` (e.g., `HEIMDALL-1804-add-webhook-retry`)
- **Feature for squad env**: `jira-issue-id-squad_name-explanation` (e.g., `COD-123-cod-new-featureX`)
- **Hotfix for production**: `hotfix-jira-issue-id-explanation` (e.g., `hotfix-HEIMDALL-1804-fix-null-pointer`)

### Commit message
- MUST contain the Jira issue ID in brackets: `[HEIMDALL-1804]`
- Format: `Description of change [JIRA-ID]`

### Important
- The `/ship` command does NOT create or rename branches — it only commits and pushes on the current branch.
- If on a PP project and the current branch is `master` or `main`, warn the user that they should be on a feature branch and ask for confirmation before proceeding.

## Important rules

- Never commit files that contain secrets (`.env`, credentials, API keys, tokens).
- If a pre-commit hook fails, fix the issue and retry with a NEW commit (never `--amend` unless explicitly asked).
- Never use `--force` push unless the user explicitly requests it.
- Never use `--no-verify` to skip hooks.
- If on `main` or `master`, warn the user before pushing directly.
