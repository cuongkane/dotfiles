JDK_LINK="/Library/Java/JavaVirtualMachines/openjdk-17.jdk"

if [ -L "$JDK_LINK" ]; then
  return 0 2>/dev/null || exit 0
fi

JDK_TARGET="$(brew --prefix openjdk@17)/libexec/openjdk.jdk"

if sudo -n true 2>/dev/null; then
  sudo ln -sfn "$JDK_TARGET" "$JDK_LINK"
else
  echo "JDK symlink needs sudo. Run manually: sudo ln -sfn $JDK_TARGET $JDK_LINK"
fi
