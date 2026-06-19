---
description: Collect lessons learned from the current session and update commands/skills/config
---

Review the current conversation to extract lessons learned, then propose updates to Claude commands, skills, or configuration files.

The arguments are: "$ARGUMENTS" (optional: target command/skill name to revise, e.g. "code-review").

## Step 1: Extract lessons

Scan the current conversation for:
- Corrections the user made to Claude's approach
- Patterns the user asked Claude to remember or repeat
- Gaps where a command/skill missed something it should have caught
- New practices or conventions discovered during the session
- Things that worked well and should be preserved

Summarize each lesson in one sentence.

## Step 2: Map lessons to targets

For each lesson, determine which file should be updated:
- **Command files** (`~/.claude/commands/*.md`) — if the lesson improves a slash command's workflow
- **Companion files** (e.g. `code-review-practices.md`) — if it's domain knowledge a command should reference
- **CLAUDE.md** (project root) — if it's a project-specific convention
- **Global CLAUDE.md** (`~/.claude/CLAUDE.md`) — if it applies across all projects
- **New file** — if no existing file is appropriate

Skip lessons that are:
- Too specific to a one-time task
- Already captured in an existing file
- Obvious from the codebase (derivable by reading code/git history)

## Step 3: Propose changes

For each target file, show the user:
1. **File**: the path
2. **Lesson**: what was learned
3. **Change**: the exact addition or edit (show the diff or new content)

Format as a numbered list so the user can approve/reject individually.

## Step 4: Wait for approval

Ask the user which changes to apply. Accept:
- "all" — apply everything
- Numbers (e.g. "1, 3, 5") — apply only those
- "none" — discard all

**Do NOT apply any changes until the user explicitly approves.**

## Step 5: Apply approved changes

Apply only the approved changes. For existing files, use Edit to make minimal, targeted changes. For new files, use Write.

After applying, list what was updated.
