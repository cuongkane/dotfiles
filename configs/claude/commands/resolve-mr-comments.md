Resolve unresolved comments on a GitLab Merge Request using the `glab` CLI.

The MR identifier is "$ARGUMENTS". If empty, default to the MR associated with the current branch.

## Workflow

### 1. Fetch unresolved discussions

Run:
```
glab mr note list $MR_ID --state unresolved -F json
```

Parse the JSON output. Each discussion has:
- `id` — the discussion ID (used to resolve it later)
- `notes` — array of notes, each with `body`, `author.username`, `position.newPath`, `position.newLine`, `position.oldPath`, `position.oldLine`

### 2. For each unresolved discussion

Present a numbered summary of ALL unresolved discussions first:
```
[1] file.py:42 — @reviewer: "Please rename this variable to be more descriptive"
[2] file.py:88 — @reviewer: "This should handle the error case"
[3] (general) — @reviewer: "Can we add a test for this?"
```

### 3. Process each discussion

For each discussion, in order:

a. **Read the relevant code** — If it's a diff note, read the file at the referenced path and line range to understand the context.

b. **Understand the request** — Analyze what the reviewer is asking for. Categorize it:
   - **Code change needed** — The reviewer wants something modified
   - **Question/clarification** — The reviewer is asking a question (do NOT auto-resolve; ask the user what to answer)
   - **Acknowledgment only** — e.g. "nit" or style suggestion the user may want to skip

c. **Take action**:
   - For code changes: make the edit, then reply to the discussion with a brief note (e.g. "Done" or "Fixed — renamed to `descriptive_name`") and resolve it.
   - For questions: show the question to the user and ask what to reply. Post the reply. Ask the user if it should be resolved.
   - For nits/optional: show it to the user and ask whether to apply it, skip it, or reply.

d. **Reply and resolve** — Use these commands:
   ```
   glab mr note $MR_ID -m "Reply message"
   glab mr note resolve $DISCUSSION_ID $MR_ID
   ```

### 4. Summary

After processing all discussions, show a summary:
```
Resolved: 5
Skipped: 1
Needs follow-up: 2
```

## Important rules

- Always read the actual code before making changes — don't guess from the diff context alone.
- Never resolve a discussion without either making the requested change or getting user confirmation to skip.
- If a comment references code you cannot find (e.g., file was renamed/deleted), flag it to the user.
- Group related discussions on the same file when possible to avoid redundant reads.
- After all code changes are done, do NOT commit automatically — let the user decide when to commit.
- The `--repo` / `-R` flag can be used if the user provides a specific repo (e.g. `GROUP/REPO`). Otherwise rely on the current git remote.
