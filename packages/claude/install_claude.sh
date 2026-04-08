if ! is_installed claude; then
  npm install -g @anthropic-ai/claude-code
fi

# Create cs shortcut for claude-squad (installed via Brewfile)
# Note: can't use `is_installed cs` because Coursier also installs a `cs` binary
BREW_CS="$(brew --prefix)/bin/cs"
if [ ! -L "$BREW_CS" ] || [ "$(readlink "$BREW_CS")" != "$(brew --prefix)/bin/claude-squad" ]; then
  ln -sf "$(brew --prefix)/bin/claude-squad" "$BREW_CS"
fi
