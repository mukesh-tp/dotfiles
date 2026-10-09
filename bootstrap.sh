#!/usr/bin/env bash
# Dotfiles bootstrap — pick which packages to symlink into $HOME via GNU Stow.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

declare -A PKG_DESC=(
  [zsh]="zsh shell config (.zshrc, .zprofile)"
  [tmux]="tmux config + plugin manager hookup"
  [git]="git identity + Git LFS config"
  [ghostty]="Ghostty terminal config"
  [karabiner]="Karabiner-Elements Hyper-key rule (macOS only)"
)
declare -A PKG_MACOS_ONLY=(
  [karabiner]=1
)

OS="$(uname -s)"

echo "Dotfiles bootstrap — $DOTFILES_DIR"
echo "Detected OS: $OS"
echo

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow not found."
  if command -v brew >/dev/null 2>&1; then
    read -rp "Install via Homebrew now? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] && brew install stow
  elif command -v apt >/dev/null 2>&1; then
    read -rp "Install via apt now (sudo)? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] && sudo apt update && sudo apt install -y stow
  elif command -v pacman >/dev/null 2>&1; then
    read -rp "Install via pacman now (sudo)? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] && sudo pacman -S --noconfirm stow
  elif command -v dnf >/dev/null 2>&1; then
    read -rp "Install via dnf now (sudo)? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] && sudo dnf install -y stow
  else
    echo "Install GNU Stow manually, then re-run this script."
    exit 1
  fi
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "stow still not available, aborting."
  exit 1
fi

names=()
for pkg in "${!PKG_DESC[@]}"; do
  names+=("$pkg")
done
IFS=$'\n' names=($(sort <<<"${names[*]}")); unset IFS

echo
echo "Available packages:"
i=1
for pkg in "${names[@]}"; do
  tag=""
  if [[ "${PKG_MACOS_ONLY[$pkg]:-0}" == 1 && "$OS" != "Darwin" ]]; then
    tag=" [macOS only — skip on this OS]"
  fi
  echo "  $i) $pkg — ${PKG_DESC[$pkg]}$tag"
  i=$((i + 1))
done

echo
read -rp "Enter package numbers to install, space-separated (e.g. 1 2 3), or 'all': " choice

selected=()
if [[ "$choice" == "all" ]]; then
  selected=("${names[@]}")
else
  for n in $choice; do
    if ! [[ "$n" =~ ^[0-9]+$ ]]; then
      echo "  Ignoring invalid input: '$n' (not a number)"
      continue
    fi
    idx=$((n - 1))
    if [[ $idx -ge 0 && $idx -lt ${#names[@]} ]]; then
      selected+=("${names[$idx]}")
    else
      echo "  Ignoring out-of-range number: $n"
    fi
  done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "Nothing selected, exiting."
  exit 0
fi

backup_conflicts() {
  local pkg="$1"
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES_DIR"/"$pkg"/}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      backup="${target}.pre-dotfiles.bak.$(date +%Y%m%d%H%M%S)"
      echo "  Backing up existing $target -> $backup"
      mv "$target" "$backup"
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
}

for pkg in "${selected[@]}"; do
  echo
  echo "== $pkg =="
  backup_conflicts "$pkg"
  # --no-folding: always symlink individual files, never collapse a whole
  # directory (e.g. ~/.config) into one symlink. Without this, stowing a
  # lone .config-touching package on a fresh $HOME turns ~/.config itself
  # into a symlink straight into this git repo, so anything another app
  # later writes under ~/.config/<app> would land inside the cloned repo.
  stow --no-folding -v -t "$HOME" "$pkg"
done

echo
echo "Done. Open a new shell (or 'exec zsh') to pick up changes."
echo "See README.md for one-time manual steps (Oh My Zsh, tpm, gh auth, atuin login, etc.)."
