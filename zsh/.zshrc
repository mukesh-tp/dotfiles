# =============================================================================
# Mukesh .zshrc
# Shell: zsh + Oh My Zsh
# Portable: macOS (Homebrew) + Linux (Homebrew/linuxbrew or apt packages)
# =============================================================================

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Keep plugin list small for faster startup.
# zsh-autosuggestions and zsh-syntax-highlighting are loaded manually below.
plugins=(git python)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# PATH setup
# -----------------------------------------------------------------------------

typeset -U path PATH

# Homebrew: macOS Apple Silicon, macOS Intel, or Linuxbrew.
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [ -x "$brew_prefix/bin/brew" ]; then
    eval "$("$brew_prefix/bin/brew" shellenv)"
    break
  fi
done

if [ -d "/opt/homebrew/opt/openjdk/bin" ]; then
  path=("/opt/homebrew/opt/openjdk/bin" $path)
fi

if [ -d "$HOME/.antigravity/antigravity/bin" ]; then
  path=("$HOME/.antigravity/antigravity/bin" $path)
fi

if [ -d "$HOME/.antigravity-ide/antigravity-ide/bin" ]; then
  path=("$HOME/.antigravity-ide/antigravity-ide/bin" $path)
fi

if [ -d "$HOME/.local/bin" ]; then
  path=($path "$HOME/.local/bin")
fi

export PATH

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Default command-line editor. Change to "nvim" if you switch later.
export EDITOR="nano"
export VISUAL="nano"

# -----------------------------------------------------------------------------
# mise / zoxide / atuin
# -----------------------------------------------------------------------------

command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

# -----------------------------------------------------------------------------
# fzf
# Fuzzy history (Ctrl+R), file (Ctrl+T), and directory (Alt+C) search.
# Modern fzf (0.48+) ships a built-in --zsh flag; fall back to the classic
# shell-script locations (Homebrew or apt) for older installs.
# -----------------------------------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    for p in \
      "/opt/homebrew/opt/fzf/shell/completion.zsh" \
      "/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.zsh" \
      "/usr/share/doc/fzf/examples/completion.zsh"; do
      [ -r "$p" ] && source "$p" && break
    done
    for p in \
      "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" \
      "/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.zsh" \
      "/usr/share/doc/fzf/examples/key-bindings.zsh"; do
      [ -r "$p" ] && source "$p" && break
    done
  fi
fi

# -----------------------------------------------------------------------------
# zsh-autosuggestions / zsh-syntax-highlighting
# Checks Homebrew (mac/linuxbrew) and apt (Debian/Ubuntu) install locations.
# -----------------------------------------------------------------------------

for p in \
  "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  [ -r "$p" ] && source "$p" && break
done

for p in \
  "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  [ -r "$p" ] && source "$p" && break
done

# -----------------------------------------------------------------------------
# macOS-only extras
# -----------------------------------------------------------------------------

if [[ "$OSTYPE" == darwin* ]]; then
  OBSIDIAN_INBOX="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/00 Inbox/Inbox.md"

  function note() {
    if [ $# -eq 0 ]; then
      echo "Usage: note <text to capture>"
      return 1
    fi
    printf -- "- [%s] %s\n" "$(date '+%Y-%m-%d %H:%M')" "$*" >> "$OBSIDIAN_INBOX"
    echo "Captured to Inbox."
  }

  alias obs="open -a Obsidian"
fi

# -----------------------------------------------------------------------------
# Local machine-only overrides (not tracked in dotfiles repo)
# -----------------------------------------------------------------------------

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
