---
name: log-tempo
description: Fill missing Tempo timesheet days for a month (default 6h/day) by inferring which Jira tickets were worked on each day from git commits, reflog branch activity across the ~/INSPECTORIO repos, and Jira status-transition history. Use when asked to "log tempo", "fill my timesheet", "log my hours", or "log work for the missing days".
version: 1.0.0
argument-hint: "[YYYY-MM] [hours-per-day]"
---

# Log Tempo for missing days

Fill each missing workday in a month with worklogs on the tickets the evidence says were
worked on. Arguments: `$ARGUMENTS` → month (`YYYY-MM`, default: current month) and hours per
day (default `6`).

## Fixed facts (verified 2026-10-21)

- Jira site / cloudId: `inspectorio.atlassian.net`. User accountId
  `712020:94f3b9e5-dda3-4004-95ec-ab8e5f9df4dc`, timezone **Asia/Jakarta (+0700)**.
- **Jira worklogs created with `mcp__atlassian__addWorklogToJiraIssue` sync into Tempo.**
- **JQL `worklogAuthor = currentUser()` does NOT see Tempo-entered hours** (it returned
  nothing while Tempo showed 30h). Read existing hours from the Tempo UI only.
- Tempo month timesheet (open in Chrome; the `/my-work/month` path is a dead link):
  ```
  https://inspectorio.atlassian.net/jira/apps/fa75e928-007a-4af4-9530-76503bcd4cba/ea7fda46-2015-4367-bd93-992fbf0c58ca/my-work/timesheet?columns=TOTAL_TIME_COLUMN&dateDisplayType=days&excludeInternalIssues=false&from=<YYYY-MM-01>&groupBy=issue&includeProjectPlans=false&includeRejectedRecords=false&includeSubtasks=false&periodType=FIXED&subPeriodType=MONTH&to=<YYYY-MM-last>&viewType=TIMESHEET&workerId=712020%3A94f3b9e5-dda3-4004-95ec-ab8e5f9df4dc
  ```
  It loads for ~10s; the grid is canvas-like (`get_page_text` returns nothing), so read it
  from screenshots. Scroll the grid left/right to see every day. The header shows
  `Total Hours N`.

## Steps

1. **Existing hours** — open the Tempo URL above, wait ~10s, screenshot. Record the
   per-day totals and the month total. A day is *missing* if it is a weekday, on or before
   yesterday, and its total is 0. Skip today unless the user asks for it (the day isn't
   over). Partially filled days: top up only to the daily target.

2. **Commits** — across all repos:
   ```bash
   cd ~/INSPECTORIO; for r in agent document-validator sight-be sight-fe; do echo "== $r"; \
     git -C $r log --all -i --author=cuong --since=<start> --until=<end+1> \
     --date=format:'%Y-%m-%d %a %H:%M' --pretty='%ad %s'; done
   ```
   For commits with no ticket key, map them to a branch:
   `git branch -a --contains <sha>` (branch names carry the ticket key).

3. **Reflog** — shows days with branch checkouts/rebases but no commits:
   ```bash
   git -C <repo> reflog --date=format:'%m-%d %a %H:%M' --pretty='%gd %gs' | grep -E '\{<MM>-'
   ```

4. **Jira transitions** — for days still without evidence, get the status history of the
   candidate tickets (`getJiraIssue` with `expand: "changelog"`). Outputs are large, so do it
   in a subagent that returns only `key | summary | transitions in range`. Candidates:
   tickets from steps 2–3, plus `assignee = currentUser() AND updated >= <start>`.
   A ticket counts for a day if it was In Development / In Code Review that day, or
   moved by the user that day.

5. **Plan** — per missing day, split the daily hours over 1–3 tickets, weighting by commit
   count/span that day. Order of preference: commits that day > reflog activity > status
   transitions > tickets In Development across that day. Keep subtask usage consistent
   with what Tempo already shows (e.g. if a parent's time was logged on a subtask, keep
   doing that).

6. **Log** — first create **one** worklog and re-open Tempo to confirm the total grew by
   exactly that amount. Then create the rest in parallel:
   `addWorklogToJiraIssue(cloudId, issueIdOrKey, timeSpent: "3h" | "1h 30m",
   started: "<YYYY-MM-DD>T09:00:00.000+0700")`. Stagger `started` within the day
   (09:00, 13:00, 14:30…) so entries don't overlap.

7. **Verify** — reload Tempo; the month total must equal old total + hours logged.
   If not, list the worklog IDs created so the user can fix them.

## Report

A table: day | ticket + hours | evidence. Then flag:
- days filled with no commit evidence (estimates)
- that per-ticket splits are estimates
- skipped days (today, days with no evidence at all) and why
- holidays/leave were not checked
