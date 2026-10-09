# Homebrew: macOS Apple Silicon, macOS Intel, or Linuxbrew.
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [ -x "$brew_prefix/bin/brew" ]; then
    eval "$("$brew_prefix/bin/brew" shellenv)"
    break
  fi
done

# pipx / user scripts
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
