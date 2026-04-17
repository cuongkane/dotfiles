Audit the dotfiles repository for consistency and issues.

## Checks

1. **Broken symlinks**: Verify every entry in `configs/install.conf.yaml` points to a file that exists in the repo
2. **Orphaned packages**: Check that every `packages/*/install_*.sh` is sourced in `packages/install_packages.sh`
3. **Orphaned configs**: Check that every `configs/*/configure_*.sh` is sourced in `configs/configure_packages.sh`
4. **Brewfile consistency**: Cross-reference `packages/Brewfile` with install scripts that use `brew install`
5. **Script safety**: Verify all shell scripts use `set -e` or equivalent error handling

Report findings as a checklist with pass/fail status for each check.
