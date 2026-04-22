#!/usr/bin/env bash
set -e

echo "======================================"
echo "Configuring tmux..."
echo "======================================"

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Install TPM if not already installed
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installed successfully!"
else
    echo "TPM is already installed, skipping..."
fi

# Install tmux plugins
echo "Installing tmux plugins..."
if [ -f "$TPM_DIR/bin/install_plugins" ]; then
    "$TPM_DIR/bin/install_plugins"
    echo "Tmux plugins installed successfully!"
else
    echo "Warning: TPM install script not found at $TPM_DIR/bin/install_plugins"
fi

# Reload tmux configuration if tmux is running
if command -v tmux &> /dev/null && [ -n "${TMUX:-}" ]; then
    echo "Reloading tmux configuration..."
    tmux source-file "$HOME/.tmux.conf"
    echo "Tmux configuration reloaded!"
elif command -v tmux &> /dev/null; then
    echo "Tmux is not currently running. Configuration will be loaded when tmux starts."
else
    echo "Warning: tmux command not found. Please install tmux first."
fi

echo "Tmux configuration completed!"
