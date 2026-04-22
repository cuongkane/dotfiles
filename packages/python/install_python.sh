pipx_install_if_missing() {
  if ! command -v "$1" &> /dev/null; then
    pipx install "$1"
  fi
}

pipx_install_if_missing black
pipx_install_if_missing ruff
pipx_install_if_missing pre-commit
