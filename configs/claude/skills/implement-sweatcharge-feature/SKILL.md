---
name: implement-sweatcharge-feature
description: Implement a vague feature request end-to-end in the SweatCharge workspace at /Users/lexuancuong/CUONG/SWC, across its Python/Django backend and Angular/TypeScript frontend as needed. Use when the user asks to implement, build, add, or change product behavior without a fully specified ticket. Creates an isolated git worktree first, then autonomously runs OpenSpec explore, propose, apply, testing, review, spec sync, archive, and opens a draft GitHub pull request. Stops only for material ambiguity.
version: 1.0.0
---

# Implement SweatCharge Feature

Turn a rough feature request into a reviewed draft GitHub pull request for SweatCharge.

## Operating contract

- Treat the user's prompt as the feature brief.
- Work only in `/Users/lexuancuong/CUONG/SWC`.
- Make creating an isolated worktree the first task and first mutation.
- After creating it, run every read, edit, build, test, git, OpenSpec, and GitHub command from the worktree.
- Progress autonomously. Do not add routine approval gates.
- Pause only for material ambiguity, as defined below.
- Archive the completed OpenSpec change after syncing it to the main specs.
- Open a **draft GitHub pull request**, never a GitLab MR or a ready-for-review PR.
- Treat the user's request to use this skill as explicit authorization to push the feature branch
  created for that request to the verified SweatCharge `origin` remote and open its draft pull
  request. This authorization covers the requested feature's committed code and specifications;
  do not ask for a second push confirmation.
- Before pushing, verify that `origin` resolves to `github.com:cuongkane/sweatcharge.git` (SSH or
  HTTPS form). Pause if it points anywhere else or if the branch contains unrelated changes.

## Workflow

Follow [references/workflow.md](references/workflow.md) phase by phase:

1. Create an isolated worktree and feature branch.
2. Explore the vague request using the repository's `openspec-explore` skill.
3. Create an apply-ready change using `openspec-propose`.
4. Implement it using `openspec-apply-change`, including tests.
5. Verify Python changes proportionally to the diff. For any frontend code or dependency change,
   run the frontend production build after implementation.
6. Review the complete branch diff and fix important findings.
7. Sync delta specs using `openspec-sync-specs`.
8. Archive the completed change using `openspec archive`.
9. Commit, push, and open a draft GitHub pull request.

The OpenSpec skills live in the target repository at `.claude/skills/<name>/SKILL.md` and are
invoked with the Skill tool by bare name (`openspec-explore`, `openspec-propose`,
`openspec-apply-change`, `openspec-sync-specs`). Read the SKILL.md from the worktree when the
invocation is unavailable in the current session and follow its steps directly.

Read these references when entering the corresponding phases:

- [references/engineering-practices.md](references/engineering-practices.md) before implementation.
- [references/testing-standards.md](references/testing-standards.md) before writing or evaluating tests.
- [references/github-delivery.md](references/github-delivery.md) before committing or opening the PR.

Always read and obey the target repository's root and affected-component instructions, including
`CLAUDE.md`, `AGENTS.md`, Feature RFC guidance, and the OpenSpec skills. Repository-local
instructions override generic advice in this skill.

## Material ambiguity

Pause and ask one concise question only when the answer:

- changes user-visible behavior, authorization, money, destructive data handling, or public API compatibility;
- selects between materially different scopes or product semantics with no clear repository precedent;
- requires credentials, external access, or authority the user has not supplied;
- conflicts with an existing OpenSpec requirement or repository instruction; or
- cannot be resolved safely from code, tests, specs, history, or established local patterns.

Do not pause for naming, file placement, test structure, implementation details, or reversible
technical choices when repository precedent provides a reasonable answer. Record consequential
assumptions in the OpenSpec proposal or design.

If ambiguity appears after proposal creation, update the affected OpenSpec artifacts after the
user answers, revalidate them, and then resume.

## Completion requirements

Do not claim completion unless:

- all apply tasks are checked off;
- changed behavior and error paths map to tests;
- any frontend code or dependency change has a successful production build from the final source
  state; rerun it after every later code fix made during verification or review;
- relevant tests, lint, formatting, type checks, builds, migrations checks, and strict OpenSpec
  validation have passed, or failures are truthfully disclosed;
- root OpenSpec main specs and affected frontend Feature RFCs are synchronized with the shipped
  behavior;
- the completed OpenSpec change is archived and all main specs pass strict validation;
- the worktree contains no unrelated changes;
- the branch is pushed; and
- a draft GitHub pull request URL is returned.

Report the worktree path, branch, OpenSpec change name, changed areas, verification results,
specs synchronized, archive location, and draft PR URL.
