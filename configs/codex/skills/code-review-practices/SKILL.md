---
name: code-review-practices
description: Review GitHub pull requests or GitLab merge requests with this user's high-signal review workflow. Use when asked to code-review a PR/MR, inspect a review URL or number, resolve review readiness, or apply the local team review practices.
---

# Code Review Practices

Prioritize real defects, behavioral regressions, and clear violations of repository instructions. Avoid style comments and speculative issues.

## Team-specific checks

Flag these when they affect changed code:

- Domain-agnostic logic inlined in service/action code when it should be a shared utility with tests.
- New public functions/actions without dedicated unit tests, even if integration tests exist.
- Complex compound boolean expressions that should be named with a descriptive variable.

## Review workflow

1. Detect GitHub vs GitLab from `git remote get-url origin`.
2. Verify authentication and repo access before fetching review data:
   - GitHub: `gh auth status`, then `gh repo view --json name -q .name`.
   - GitLab: `glab auth status`, then `glab repo view`.
3. Fetch the PR/MR title, description, comments, and diff.
4. Stop without reviewing if the PR/MR is closed, merged, draft, automated/trivial, or already reviewed by Claude/Codex unless the user explicitly asks to continue.
5. Read relevant repository instruction files, especially root `CLAUDE.md`, `AGENTS.md`, and any nearer instruction files for modified paths.
6. Review only high-confidence issues:
   - Syntax, type, import, or unresolved-reference failures.
   - Logic that will clearly produce wrong results.
   - Security or data-loss defects visible in the changed code.
   - Clear instruction violations with a file/line reference.
7. Filter out pre-existing issues, linter-only nits, subjective style comments, and anything that depends on unverified assumptions.

## Output and comments

Lead with findings ordered by severity and include file/line references. If no issues are found, say so plainly and mention any test gaps or residual risk.

Only post comments when the user asks for `--comment` or clearly asks you to publish the review. Post one comment per unique issue. Use inline comments when the platform and tooling support them; otherwise post concise MR/PR notes with file and line references.
