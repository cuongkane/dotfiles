if is_installed pyenv; then
  print_package_version pyenv
  if ! pyenv versions --bare | grep -q "^3\.11"; then
    echo "Installing Python 3.11 via pyenv..."
    pyenv install 3.11
    pyenv global 3.11
  fi
else
  echo "pyenv not found — ensure it is in the Brewfile"
  return 1
fi
