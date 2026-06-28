if ! is_installed playwright; then
  npm install -g playwright
fi

if is_installed playwright; then
  playwright install chromium
fi
