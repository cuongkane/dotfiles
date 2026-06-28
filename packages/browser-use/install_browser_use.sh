if ! is_installed browser-use; then
  uv tool install --python 3.11 "browser-use[core]"
fi

if is_installed browser-use; then
  browser-use install
fi
