# Dotfiles

MacOS development environment setup managed with shell scripts and [Dotbot](https://github.com/anishathalye/dotbot).

## Structure

- `packages/` - Installation scripts for each tool (one directory per package)
- `configs/` - Configuration files and setup scripts (symlinked via Dotbot)
- `utils/` - Shared helper functions (colors, symlinks, version printing)
- `install.sh` - Main entrypoint: installs packages, then configures them
- `configs/install.conf.yaml` - Dotbot symlink manifest

## Conventions

- Each package has its own directory under `packages/<name>/install_<name>.sh`
- Each config has its own directory under `configs/<name>/` with the dotfile and optional `configure_<name>.sh`
- Symlinks are declared in `configs/install.conf.yaml` (Dotbot format)
- Brew packages go in `packages/Brewfile`
- Scripts use `set -e` and source helpers from `utils/load_utils.sh`
- The install pipeline is: `install.sh` -> `install_packages.sh` -> `configure_packages.sh`
