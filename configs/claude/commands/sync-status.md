Check which dotfiles are currently synced and which are out of date.

## Steps

1. Read `configs/install.conf.yaml` to get all symlink mappings
2. For each mapping, check:
   - Does the source file exist in the repo?
   - Does the symlink exist at the target location?
   - Is the symlink pointing to the correct source?
3. Report a table with columns: Target, Source, Status (linked/missing/stale)
