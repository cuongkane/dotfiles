#!/usr/bin/env bash

COMMANDS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.claude/commands" && pwd)"
COMMANDS_DST="$HOME/.claude/commands"

mkdir -p "$COMMANDS_DST"

for file in "$COMMANDS_SRC"/*.md; do
  [ -f "$file" ] || continue
  name="$(basename "$file")"
  target="$COMMANDS_DST/$name"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$file" ]; then
    continue
  fi
  create_symlink "$file" "$target"
done
