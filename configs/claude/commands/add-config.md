Add or update configuration for "$ARGUMENTS" in the dotfiles.

## Steps

1. Check if `configs/$ARGUMENTS/` already exists
2. If not, create the directory and the config file(s) for the tool
3. Add or update the symlink entry in `configs/install.conf.yaml` (Dotbot format)
4. If a setup script is needed, create `configs/$ARGUMENTS/configure_$ARGUMENTS.sh` and source it in `configs/configure_packages.sh`
5. Show the symlink mapping and any manual steps needed
