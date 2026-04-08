Show differences between the repo config files and the currently active ones on the system for "$ARGUMENTS" (or all if no argument given).

## Steps

1. Read `configs/install.conf.yaml` to get symlink mappings
2. If an argument is provided, filter to only that tool's config
3. For each mapping, diff the repo file against the live file at the target path
4. Report which configs are identical, modified, or missing
