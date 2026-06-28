source "packages/brew/install_brew.sh"
brew bundle --file=packages/Brewfile --no-upgrade

# Self-heal broken brew packages (e.g. shared library version mismatches)
if command -v brew >/dev/null 2>&1; then
  broken=$(brew missing 2>/dev/null || true)
  if [ -n "$broken" ]; then
    printf "%b\n" "${YELLOW}Repairing broken brew packages...${NC}"
    echo "$broken" | cut -d: -f1 | xargs brew reinstall
  fi
fi

source "packages/zsh/install_zsh.sh"
source "packages/xcode/install_xcode.sh"
source "packages/pyenv/install_pyenv.sh"
source "packages/npm/install_npm.sh"
source "packages/neovim/install_neovim.sh"
source "packages/rosetta/install_rosetta.sh"
source "packages/claude/install_claude.sh"
source "packages/aws/install_aws.sh"
source "packages/python/install_python.sh"
source "packages/java/install_java.sh"
source "packages/coursier/install_coursier.sh"
source "packages/rtk/install_rtk.sh"
