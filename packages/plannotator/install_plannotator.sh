set -e

if ! is_installed plannotator; then
  curl -fsSL https://plannotator.ai/install.sh | bash
fi

print_package_version plannotator
