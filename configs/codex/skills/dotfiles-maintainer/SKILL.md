---
name: dotfiles-maintainer
description: Maintain this dotfiles repository. Use when adding or updating a package installer, adding or updating a managed config, auditing package/config consistency, checking Dotbot symlink status, or diffing live dotfiles against repo-managed files.
---

# Dotfiles Maintainer

Use the repo's existing conventions:

- Package installers live at `packages/<name>/install_<name>.sh`.
- Package installers are sourced from `packages/install_packages.sh`.
- Config files live under `configs/<name>/`.
- Dotbot symlinks are declared in `configs/install.conf.yaml`.
- Config setup scripts are named `configs/<name>/configure_<name>.sh` and sourced from `configs/configure_packages.sh`.
- Brew packages belong in `packages/Brewfile`.

## Add a package

When asked to add a package:

1. Create `packages/<name>/install_<name>.sh` with the installation commands.
2. Source it from `packages/install_packages.sh` in the existing order.
3. If it is installed by Homebrew, add it to `packages/Brewfile`.
4. If it has managed config files, also create `configs/<name>/`, add Dotbot symlinks, and add a configure script only when post-install work is needed.
5. Report the files created or changed and any manual steps.

## Add a config

When asked to add or update a config:

1. Check whether `configs/<name>/` already exists.
2. Add or update the config files there.
3. Add or update the symlink entry in `configs/install.conf.yaml`.
4. Add `configs/<name>/configure_<name>.sh` and source it from `configs/configure_packages.sh` only when setup cannot be represented as a symlink.
5. Show the target-to-source symlink mapping and any manual steps.

## Audit

When asked to audit this repo, check:

1. Every source in `configs/install.conf.yaml` exists.
2. Every `packages/*/install_*.sh` is sourced in `packages/install_packages.sh`.
3. Every `configs/*/configure_*.sh` is sourced in `configs/configure_packages.sh`.
4. Brewfile entries and install scripts are not obviously duplicated or contradictory.
5. Shell scripts use `set -e` or another clear failure strategy.

Report findings as a checklist with concrete file references.

## Sync and diff

For sync status, read `configs/install.conf.yaml` and check whether each target exists, is a symlink, and points to the expected source.

For config diffs, compare each mapped repo source with the live target. If the user provides a tool name, filter to mappings for that tool.
