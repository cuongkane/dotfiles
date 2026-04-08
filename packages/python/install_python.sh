installed_pip_pkgs="$(pip list --format=columns 2>/dev/null)"

pip_install_if_missing() {
  local pattern="$(echo "$1" | sed 's/[-_]/[-_]/g')"
  if ! echo "$installed_pip_pkgs" | grep -qi "^${pattern} "; then
    pip install "$1"
  fi
}

pip_install_if_missing black
pip_install_if_missing ruff
pip_install_if_missing pre-commit
