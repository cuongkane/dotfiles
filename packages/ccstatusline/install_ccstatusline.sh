if is_installed ccstatusline; then
  print_package_version ccstatusline
else
  npm install -g ccstatusline
fi
