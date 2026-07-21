# Git conventions & draft MR

Source of truth: Inspectorio **GIT Conventions**
(https://inspectorio.atlassian.net/wiki/spaces/ED/pages/54493423) — encoded below.

## Branch naming

`<type>/<ticket-id>/<subject>` — subject in `kebab-case`.

| Pattern | Use for | Example |
| --- | --- | --- |
| `feature/<ticket-id>/<subject>` | a new feature | `feature/SE-22/add-email-notification` |
| `fix/<ticket-id>/<subject>` | a bug fix | `fix/I2-52/missing-validation` |
| `chore/<ticket-id>/<subject>` | refactor, clean-up, performance, other chores | `chore/I2-13/improve-batch-filter-performance` |

Pick the type from the ticket's nature. Create with:
```
git checkout -b feature/<ticket-id>/<subject>
```

## Commit message

- Subject **≤ 50 characters**.
- Imperative mood — start with a **verb** ("Add", "Fix", "Remove").
- Start with `[<ticket-id>]`, e.g. `[ID2-123456]`. Chores with no ticket: `[Chore]`.
- Migration commits also include `[Migration]` (or `[Data Migration]`), e.g.
  `[ID2-123456][Migration] Add column type to student`.
- **No period** at the end of the subject.
- Add a body ("what" and "why") when the change isn't self-evident.

| Good | Bad |
| --- | --- |
| `[ID-211] Add auth to file controller` | `adding authorization.` |
| `[ID-211][Migration] Add column type to student` | `[ID-211]Add column type to student` |
| `[ID-001] Remove unused legacy methods` | `just removing a bunch of crap` |

### Pair programming trailers
```
[ID-211] Add auth to file controller

Co-authored-by: John Doe <johndoe@inspectorio.com>
Co-authored-by: Jolie <jolie@inspectorio.com>
```

## Best practices

- Rebase your branch on the target (`master`/`main`) before opening/accepting the MR, and
  regularly, to avoid conflicts (`git pull --rebase --autostash`).
- Squash commits that are too small/verbose.
- Delete the branch once merged.

## Open the MR as Draft

**Required outcome:** commit → push → open a **Draft** MR, titled `[<TICKET>] <subject>`, with a
real description (see the template below), against the correct target branch, with the ticket
linked. The MR must open in **Draft** status — never mark it ready automatically. After creation,
report the MR URL to the user.

Use the GitLab CLI to open it. Illustrative example (adapt flags to your CLI version — the
outcome above is the contract, not these exact flags):
```
git add -A
git commit -m "[<TICKET>] <Imperative subject ≤50 chars>"   # add body / trailers as needed
git push -u origin HEAD

glab mr create --draft \
  --title "[<TICKET>] <subject>" \
  --description "<MR description — see template below>" \
  --target-branch <target>
```

## MR description template

Follow the `concisely-propose-solution` style — objective, numbered, numbers over adjectives.

```markdown
## Context
<System/repo and why this area matters.>

## Problem
<What the ticket asks for. Ends with: Ticket <TICKET> (<jira-url>).>

## Solution
<One sentence on the approach, then the key changes as bullets with `paths`/identifiers.>

## Tests
- <Test cases added, one behavior each.>
- Coverage: each new/changed path + acceptance criterion has a test (verified by diff → test
  mapping, not a coverage tool). <Note any deliberately-untested path + why.>

## Notes for reviewers
- <Behavior changes, migrations, follow-ups, anything needing confirmation.>
```
