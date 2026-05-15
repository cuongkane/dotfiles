---
allowed-tools: Bash(git remote:*), Bash(git rev-parse:*), Bash(gh auth:*), Bash(gh repo:*), Bash(gh issue view:*), Bash(gh search:*), Bash(gh issue list:*), Bash(gh pr comment:*), Bash(gh pr diff:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(glab auth:*), Bash(glab repo:*), Bash(glab mr view:*), Bash(glab mr diff:*), Bash(glab mr list:*), Bash(glab mr note:*), mcp__github_inline_comment__create_inline_comment
description: Code review a pull request or merge request
---

Provide a code review for the given pull request (GitHub) or merge request (GitLab).

The argument is: "$ARGUMENTS" (PR/MR number or URL, plus optional flags like `--comment`).

**Agent assumptions (applies to all agents and subagents):**
- All tools are functional and will work without error. Do not test tools or make exploratory calls. Make sure this is clear to every subagent that is launched.
- Only call a tool if it is required to complete the task. Every tool call should have a clear purpose.

## Step 0: Detect platform and verify access

Determine whether this repository uses **GitHub** or **GitLab** by checking the git remote:

```bash
git remote get-url origin
```

- If the remote URL contains `github.com` → use **GitHub** (`gh` CLI)
- If the remote URL contains `gitlab` → use **GitLab** (`glab` CLI)
- If ambiguous, check for both and pick whichever resolves

Then verify CLI access for the detected platform:

**For GitHub:**
```bash
gh auth status
```
If this fails (not logged in, token expired, etc.), stop immediately and inform the user:
> "GitHub CLI is not authenticated. Please run `gh auth login` to authenticate before running /code-review."

**For GitLab:**
```bash
glab auth status
```
If this fails, stop immediately and inform the user:
> "GitLab CLI is not authenticated. Please run `glab auth login` to authenticate before running /code-review."

Also verify the CLI can access the specific repository:

**For GitHub:**
```bash
gh repo view --json name -q .name
```

**For GitLab:**
```bash
glab repo view
```

If repo access fails, stop and inform the user:
> "Cannot access the repository via [gh/glab]. Check your permissions and that the remote is correctly configured."

**Do not proceed past this step if authentication or repo access fails.**

---

From this point forward, use the appropriate CLI commands based on the detected platform. The instructions below use `gh` / "PR" terminology but should be substituted with `glab` / "MR" equivalents when on GitLab:

| GitHub (`gh`)                        | GitLab (`glab`)                        |
|--------------------------------------|----------------------------------------|
| `gh pr view <N>`                     | `glab mr view <N>`                     |
| `gh pr view <N> --comments`          | `glab mr view <N> --comments`          |
| `gh pr diff <N>`                     | `glab mr diff <N>`                     |
| `gh pr comment <N> -b "..."`         | `glab mr note <N> -m "..."`            |
| `gh pr view <N> --json ...`          | `glab mr view <N> -F json`             |
| PR (pull request)                    | MR (merge request)                     |

---

## Step 1: Pre-check — should we review?

Launch a haiku agent to check if any of the following are true:
- The PR/MR is closed or merged
- The PR/MR is a draft
- The PR/MR does not need code review (e.g. automated PR, trivial change that is obviously correct)
- Claude has already commented on this PR/MR (check comments for comments left by Claude)

If any condition is true, stop and do not proceed.

Note: Still review Claude-generated PRs/MRs.

## Step 2: Find CLAUDE.md files

Launch a haiku agent to return a list of file paths (not their contents) for all relevant CLAUDE.md files including:
- The root CLAUDE.md file, if it exists
- Any CLAUDE.md files in directories containing files modified by the PR/MR

## Step 3: Summarize changes

Launch a sonnet agent to view the PR/MR and return a summary of the changes.

## Step 4: Parallel review agents

Launch 4 agents in parallel to independently review the changes. Each agent should return a list of issues, where each issue includes a description and the reason it was flagged (e.g. "CLAUDE.md adherence", "bug"). The agents should do the following:

**Agents 1 + 2: CLAUDE.md compliance sonnet agents**
Audit changes for CLAUDE.md compliance in parallel. Note: When evaluating CLAUDE.md compliance for a file, you should only consider CLAUDE.md files that share a file path with the file or parents.

**Agent 3: Opus bug agent (parallel with agent 4)**
Scan for obvious bugs. Focus only on the diff itself without reading extra context. Flag only significant bugs; ignore nitpicks and likely false positives. Do not flag issues that you cannot validate without looking at context outside of the git diff.

**Agent 4: Opus bug agent (parallel with agent 3)**
Look for problems that exist in the introduced code. This could be security issues, incorrect logic, etc. Only look for issues that fall within the changed code.

**Team-specific review practices:** Read `~/.claude/commands/code-review-practices.md` if it exists, and include those patterns as additional review criteria for all agents.

**CRITICAL: We only want HIGH SIGNAL issues.** Flag issues where:
- The code will fail to compile or parse (syntax errors, type errors, missing imports, unresolved references)
- The code will definitely produce wrong results regardless of inputs (clear logic errors)
- Clear, unambiguous CLAUDE.md violations where you can quote the exact rule being broken

Do NOT flag:
- Code style or quality concerns
- Potential issues that depend on specific inputs or state
- Subjective suggestions or improvements

If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.

In addition to the above, each subagent should be told the PR/MR title and description. This will help provide context regarding the author's intent.

## Step 5: Validate issues

For each issue found in step 4 by agents 3 and 4, launch parallel subagents to validate the issue. These subagents should get the PR/MR title and description along with a description of the issue. The agent's job is to review the issue to validate that the stated issue is truly an issue with high confidence. Use Opus subagents for bugs and logic issues, and sonnet agents for CLAUDE.md violations.

## Step 6: Filter

Filter out any issues that were not validated in step 5. This gives us our list of high-signal issues.

## Step 7: Output summary

Output a summary of the review findings to the terminal:
- If issues were found, list each issue with a brief description.
- If no issues were found, state: "No issues found. Checked for bugs and CLAUDE.md compliance."

If `--comment` argument was NOT provided, stop here. Do not post any comments.

If `--comment` argument IS provided and NO issues were found, post a summary comment and stop:
- **GitHub**: `gh pr comment <N> -b "..."`
- **GitLab**: `glab mr note <N> -m "..."`

If `--comment` argument IS provided and issues were found, continue to step 8.

## Step 8: Plan comments

Create a list of all comments you plan on leaving. This is only for you to verify you are comfortable with the comments. Do not post this list anywhere.

## Step 9: Post inline comments

**For GitHub:**
Post inline comments for each issue using `mcp__github_inline_comment__create_inline_comment` with `confirmed: true`. For each comment:
- Provide a brief description of the issue
- For small, self-contained fixes, include a committable suggestion block
- For larger fixes (6+ lines, structural changes, or changes spanning multiple locations), describe the issue and suggested fix without a suggestion block
- Never post a committable suggestion UNLESS committing the suggestion fixes the issue entirely

**For GitLab:**
Post comments on the MR using `glab mr note <MR_ID> -m "..."`. For each comment:
- Provide a brief description of the issue and the file/line reference
- For small, self-contained fixes, include a code suggestion
- For larger fixes, describe the issue and suggested fix

**IMPORTANT: Only post ONE comment per unique issue. Do not post duplicate comments.**

---

## False positive list

Use this list when evaluating issues in Steps 4 and 5 (these are false positives, do NOT flag):

- Pre-existing issues
- Something that appears to be a bug but is actually correct
- Pedantic nitpicks that a senior engineer would not flag
- Issues that a linter will catch (do not run the linter to verify)
- General code quality concerns (e.g., lack of test coverage, general security issues) unless explicitly required in CLAUDE.md
- Issues mentioned in CLAUDE.md but explicitly silenced in the code (e.g., via a lint ignore comment)

## Notes

- Use the appropriate CLI (`gh` or `glab`) for all platform interactions. Do not use web fetch.
- Create a todo list before starting.
- You must cite and link each issue in inline comments (e.g., if referring to a CLAUDE.md, include a link to it).
- If no issues are found and `--comment` argument is provided, post a comment with the following format:

---

## Code review

No issues found. Checked for bugs and CLAUDE.md compliance.

---

- **GitHub link format** (for inline comments): `https://github.com/OWNER/REPO/blob/FULL_SHA/path/to/file#L10-L15`
  - Requires full git SHA (not abbreviated)
  - You must provide the full SHA. Commands like `$(git rev-parse HEAD)` will not work in Markdown rendering.
  - `#` sign after the file name
  - Line range format is `L[start]-L[end]`
  - Provide at least 1 line of context before and after

- **GitLab link format** (for MR comments): `https://<GITLAB_HOST>/GROUP/REPO/-/blob/FULL_SHA/path/to/file#L10-15`
  - Use the actual GitLab host from the git remote (e.g. `git.parcelperform.com`, `gitlab.com`)
  - Requires full git SHA
  - Uses `/-/blob/` path format
  - Line range format is `L[start]-[end]`
