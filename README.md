# dotfiles

Personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level folder is a self-contained "package" that mirrors `$HOME` —
you choose which packages to symlink in on any given machine, nothing is
forced on you.

## Why Stow

No templating language, no special format — every file here is exactly what
lands in your home directory, just symlinked instead of copied. Works the
same on macOS and Linux (anything Unix-like). Pick what you want per machine:
a throwaway Linux VM might only get `zsh` + `tmux`; this Mac gets everything.

## Quick start

```bash
git clone <this repo> ~/dotfiles   # or wherever you keep it
cd ~/dotfiles
./bootstrap.sh
```

The script installs `stow` if it's missing (via brew/apt/pacman/dnf), lists
the available packages, flags which ones are macOS-only, and lets you pick
which to activate. It backs up any real (non-symlink) file already at the
target path as `<file>.pre-dotfiles.bak.<timestamp>` before stowing, so it's
safe to run against an existing home directory.

To add or remove a package later, just re-run `./bootstrap.sh`, or run stow
directly: `stow --no-folding -t ~ <package>` / `stow -D -t ~ <package>` (to
remove). Always include `--no-folding` — without it, stowing a lone
`.config`-touching package on a fresh `$HOME` turns `~/.config` itself into
a symlink straight into this repo, so anything another app later writes
under `~/.config/<app>` would land inside the cloned git repo instead of a
normal directory. `bootstrap.sh` already does this for you.

## Packages

| Package     | What it covers                                   | Portability   |
|-------------|---------------------------------------------------|---------------|
| `zsh`       | `.zshrc`, `.zprofile`                              | macOS + Linux |
| `tmux`      | `.tmux.conf`                                       | macOS + Linux |
| `git`       | `.gitconfig` (identity + Git LFS)                  | macOS + Linux |
| `ghostty`   | Ghostty terminal config                            | macOS + Linux |
| `karabiner` | Hyper-key (Caps Lock → Escape/Hyper) complex mod   | **macOS only** |

Linux-only or Windows-only packages can be added the same way later — just
make a new top-level folder mirroring the home-directory path and add it to
`PKG_DESC` (and `PKG_MACOS_ONLY`/an equivalent tag) in `bootstrap.sh`.

## What's deliberately NOT in this repo

Secrets and machine-specific auth never belong in git, even a private repo:

- **GitHub CLI (`gh`) auth** — run `gh auth login` fresh on each machine.
- **Atuin sync/login** — run `atuin login` fresh on each machine if you want
  history sync; local-only history works with no login at all.
- **Git credential helper** — differs by OS (Git Credential Manager on
  macOS/Windows, `libsecret` or similar on Linux). Set it per machine with
  `git config --global credential.helper <...>`, or drop it in
  `~/.gitconfig.local` (auto-included by the tracked `.gitconfig`, never
  tracked itself).
- Any other machine-only shell tweaks go in `~/.zshrc.local`, which the
  tracked `.zshrc` sources automatically if present.

## One-time manual steps per machine (not automated by bootstrap.sh)

These are third-party installs, not config — intentionally not vendored:

- **Oh My Zsh**: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- **zsh-autosuggestions** / **zsh-syntax-highlighting**: `brew install zsh-autosuggestions zsh-syntax-highlighting` (macOS/Linuxbrew) or `apt install zsh-autosuggestions zsh-syntax-highlighting` (Debian/Ubuntu)
- **tmux plugin manager (tpm)**: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then `prefix + I` inside tmux to install plugins
- **mise**, **zoxide**, **atuin**, **fzf**: install per their own docs; `.zshrc` auto-detects and activates each if present, no config needed to get started. (`mise`/`atuin` have no real config of their own yet — see the note below.)
- **Karabiner-Elements**: install the app, then enable the "Caps Lock tapped = Escape, held = Hyper" rule under Preferences → Complex Modifications → Add rule (the JSON this package symlinks in makes it available to enable, but Karabiner's own UI toggle still has to be flipped on)

## Tools without a package (checked, deliberately skipped)

- **mise**, **atuin** — checked both on 2026-10-09: no real config file/customization exists for either yet (atuin's `config.toml` is 100% stock defaults, mise has no config file at all). Vendoring them now would just duplicate what the tool writes itself on first run. Add a real package for one the first time it's actually customized.
- **fzf** — no config file to vendor (it doesn't use one), but its shell integration (Ctrl+R history, Ctrl+T file, Alt+C directory search) is wired into `zsh/.zshrc` directly, checking both the modern `fzf --zsh` flag and classic Homebrew/apt shell-script paths as a fallback.

## Repo layout convention

```
<package>/<path mirroring $HOME>
```

e.g. `zsh/.zshrc` → symlinked to `~/.zshrc`, `ghostty/.config/ghostty/config.ghostty` → `~/.config/ghostty/config.ghostty`.
