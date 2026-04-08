if ! is_installed npm; then
  curl -L https://www.npmjs.com/install.sh | sh
fi
print_package_version npm

npm_install_if_missing() {
  if ! is_installed "$1"; then
    npm install -g "$1"
  fi
}

npm_install_if_missing yarn
npm_install_if_missing tsc
npm_install_if_missing typescript-language-server
