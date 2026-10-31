function install_ohmyzsh {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN} ✓ oh-my-zsh is already installed ${NC}"
  else
    echo " 📦 Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
    echo -e " ${GREEN}✓${NC} oh-my-zsh installed successfully"
  fi
  # Set ZSH_CUSTOM for plugins installation
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo " 📦 Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo -e " ${GREEN}✓${NC} zsh-autosuggestions installed successfully"
  else
    echo -e " ${GREEN}✓${NC} zsh-autosuggestions plugin is already installed"
  fi
  # zsh-defer lazy-loads plugins in zshrc so the prompt appears immediately
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-defer" ]; then
    echo " 📦 Installing zsh-defer plugin..."
    git clone https://github.com/romkatv/zsh-defer "$ZSH_CUSTOM/plugins/zsh-defer"
    echo -e " ${GREEN}✓${NC} zsh-defer installed successfully"
  else
    echo -e " ${GREEN}✓${NC} zsh-defer plugin is already installed"
  fi
}

install_ohmyzsh
if ! is_installed oh-my-posh; then
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
fi
