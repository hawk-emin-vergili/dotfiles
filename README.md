# dotfiles

Personal macOS (zsh) dotfiles. Manages shell config, git config, Homebrew packages, and dev tooling via symlinks.

## Quick start

```bash
make install   # interactive full setup — prompts for each step
```

## Individual targets

```bash
make link           # symlink dotfiles into ~ (backs up existing as .bak)
make unlink         # remove symlinks, restore backups
make brew           # install Homebrew packages from Brewfile
make claude         # merge personal Claude Code plugin settings
make ssh            # add GitHub SSH config via Include directive
make macos          # apply macOS defaults (Dock, keyboard, screenshots)
make raycast        # import Raycast settings
make obsidian       # symlink Obsidian vault settings
make chrome         # restore Chrome bookmarks from encrypted backup
make chrome-backup  # backup Chrome bookmarks to password-protected zip
make skills         # clone agent skills repo and symlink into Claude Code
make hawk           # run Hawk AI developer setup (see hawk/README.md)
```

## How it works

The Makefile defines `source:destination` pairs (e.g., `zshrc:.zshrc`). `make link` symlinks each into `$HOME`, backing up any existing file first.

Secrets and machine-specific config go in `~/.zshrc.local` (gitignored).
