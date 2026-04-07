# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repo for macOS (zsh). Manages shell config, git config, and Homebrew packages via symlinks from this repo into `~`.

## Commands

```bash
make install        # interactive full setup — prompts for each step
make link           # symlink dotfiles into ~ (backs up existing as .bak)
make unlink         # remove symlinks, restore .bak backups
make brew           # install Homebrew packages from Brewfile
make claude         # merge personal Claude Code plugin settings
make ssh            # add GitHub SSH config via Include directive
make macos          # apply macOS defaults (Dock, keyboard, screenshots)
make raycast        # import Raycast settings
make obsidian       # symlink Obsidian vault settings
make chrome         # restore Chrome bookmarks from encrypted backup
make chrome-backup  # backup Chrome bookmarks to password-protected zip
make skills         # clone agent skills repo and symlink into Claude Code
make hawk           # run Hawk AI developer setup (delegates to hawk/Makefile)
make help           # list available targets
```

## How It Works

The Makefile defines a `LINKS` mapping of `source:destination` pairs (e.g., `zshrc:.zshrc`). `make link` symlinks each source file into `$HOME` with the destination name, backing up any existing file first. `make unlink` reverses this.

Machine-specific secrets go in `~/.zshrc.local` (gitignored via `*.local` pattern). The example template is `zshrc.local.example`.

## Key Files

- **zprofile** — Homebrew init, JetBrains Toolbox PATH
- **zshrc** — aliases, shell functions (`merge2dev`, `gmaster`, `greview`), NVM/SDKMAN init; sources `~/.zshrc.local` at the end
- **gitconfig** — user identity, `push.autoSetupRemote=true`, `pull.ff=only`
- **Brewfile** — CLI tools (gh, git, helm, jq, k9s, kubernetes-cli, kustomize, nvm, tldr, uv) and cask apps (Bruno, Docker Desktop, IntelliJ, JetBrains Toolbox, Obsidian, Raycast, Slack, tsh, Warp, Zoom)
- **chrome_bookmarks.zip** — password-protected Chrome bookmarks backup
- **obsidian/** — Obsidian vault settings (app.json, appearance.json, core-plugins.json, graph.json)
- **hawk/** — Hawk AI developer setup module (self-contained, role-based). See `hawk/README.md`.
- **SPEC.md** — design principles and hard requirements for this repo

## Conventions

- When adding a new dotfile, add its `source:destination` pair to the `LINKS` variable in the Makefile.
- Never commit `*.local` files — they contain secrets.
