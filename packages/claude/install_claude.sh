npm install -g @anthropic-ai/claude-code

# Create cs shortcut for claude-squad (installed via Brewfile)
ln -sf "$(brew --prefix)/bin/claude-squad" "$(brew --prefix)/bin/cs"

# Install ccstatusline for Claude Code status line
npx -y ccstatusline@latest
