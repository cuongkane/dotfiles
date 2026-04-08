Add a new package "$ARGUMENTS" to the dotfiles setup.

## Steps

1. Create `packages/$ARGUMENTS/install_$ARGUMENTS.sh` with the installation commands
2. Add the package source line to `packages/install_packages.sh`
3. If it's a brew package, also add it to `packages/Brewfile`
4. If the package needs configuration files:
   - Create `configs/$ARGUMENTS/` with the config file(s)
   - Add symlink entries to `configs/install.conf.yaml`
   - If post-install configuration is needed, create `configs/$ARGUMENTS/configure_$ARGUMENTS.sh` and source it in `configs/configure_packages.sh`
5. Show a summary of all files created/modified
