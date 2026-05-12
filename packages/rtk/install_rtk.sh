if is_installed rtk; then
  print_package_version rtk
else
  echo "rtk not found — ensure it is in the Brewfile"
  return 1
fi
