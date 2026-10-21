# Database access

The local port-forward on `127.0.0.1:5434` reaches the **production primary**, not a replica
(`pg_is_in_recovery() = f`). Nothing you run can change data — but everything you run costs
production CPU. Treat cost, not corruption, as the risk to manage.

## Why read-only is guaranteed

The account has **no write privileges on any table** and no superuser rights. Verified:

```
tables_total | can_update | can_insert | can_delete
         486 |          0 |          0 |          0
rolsuper=f  rolcreatedb=f  rolcreaterole=f  rolbypassrls=f
```

The server refuses writes; this does not depend on the agent behaving. Re-verify on a new
environment or a changed account before trusting it — the check is at the bottom of this file.

`default_transaction_read_only=on` in the recipe below is defense in depth, and it also blocks DDL
that grants alone might permit (temp tables, `SET`-based side effects).

## The invocation

Use `psql`, not `pgcli` — pgcli is interactive and cannot be driven from a tool call.

```bash
PGOPTIONS='-c default_transaction_read_only=on -c statement_timeout=10000 -c lock_timeout=3000 -c idle_in_transaction_session_timeout=15000' \
psql "host=127.0.0.1 port=5434 dbname=sight-be user=<user> sslmode=disable" \
  --no-psqlrc -v ON_ERROR_STOP=1 -P pager=off -A -F$'\t' \
  -c "<one statement>;"
```

- `statement_timeout=10000` — 10s ceiling. A well-targeted investigative query returns in
  milliseconds; hitting this means the query was wrong, not that the timeout was too low.
- `lock_timeout` / `idle_in_transaction_session_timeout` — never hold anything on the primary.
- `-A -F$'\t'` — unaligned tab-separated output; parses cleanly and avoids psql's padded tables,
  which mangle JSON columns and defeat grep.
- `--no-psqlrc` — ignore local settings so behavior is reproducible.
- One statement per `-c`. Repeat `-c` for several; they run in order in one session.

Raising the timeout above 10s needs a stated reason and an `EXPLAIN` that justifies it. Never
disable it.

## Keeping queries cheap

- **Anchor on identity.** Filter by `uuid`, `id`, or another indexed key. An incident is about one
  record; find it directly rather than scanning for it.
- **Bound every aggregate.** `COUNT(*)` needs a `WHERE` — an org, a date window, or both. Unbounded
  counts on the big tables (`lab_test_labtest`, bookings, inspections) are seq scans on the primary.
- **`EXPLAIN` before running anything unbounded.** Plain `EXPLAIN`, never `EXPLAIN ANALYZE` (that
  executes it). If the estimate is in the millions, narrow the query instead of running it.
- **`LIMIT` exploratory queries**, even ones you expect to return few rows.
- **Do not `ORDER BY` a large set** just to see the top few — add the filter that makes it small.
- **Never** `VACUUM`, `ANALYZE`, or anything that touches server state, even where permitted.
- Prefer several small targeted queries over one wide join. They are easier to read, cheaper to run,
  and a wrong one costs less.

## Failure modes

- **Connection refused** — the tunnel is down. Ask the user to restart it; do not proceed on
  assumptions or substitute a local dump without saying so.
- **`relation does not exist`** — a guessed table name. `sight-be` uses Django defaults
  (`<app>_<modelname>`, lowercase, no underscore inside the model part) unless `db_table` is set.
- **`canceling statement due to statement timeout`** — the query was too broad. Narrow it; do not
  raise the ceiling reflexively.
- **`permission denied`** — expected for anything that writes. Report it as confirmation of the
  read-only guarantee, not as a blocker to work around.

## Re-verifying the read-only guarantee

Run on a new environment, a changed account, or if anything about access looks different:

```sql
SELECT current_database(), current_user, pg_is_in_recovery() AS is_replica,
       current_setting('default_transaction_read_only') AS session_read_only;

SELECT rolsuper, rolcreatedb, rolcreaterole, rolbypassrls
FROM pg_roles WHERE rolname = current_user;

SELECT count(*) AS tables_total,
       count(*) FILTER (WHERE has_table_privilege(current_user, c.oid, 'UPDATE')) AS can_update,
       count(*) FILTER (WHERE has_table_privilege(current_user, c.oid, 'INSERT')) AS can_insert,
       count(*) FILTER (WHERE has_table_privilege(current_user, c.oid, 'DELETE')) AS can_delete
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','p') AND n.nspname NOT IN ('pg_catalog','information_schema');
```

Any non-zero write count means the account is **not** read-only. Stop, tell the user, and go back to
handing them SQL to run themselves.
