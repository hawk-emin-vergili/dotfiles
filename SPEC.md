# Spec

Design principles and hard requirements for this dotfiles repo.

## Hard Requirements

### Idempotent installation

`make install` must be safe to run multiple times. When a step fails, the user fixes the issue and re-runs `make install` — previously completed steps must skip gracefully without side effects. This applies to all Makefile targets (`link`, `brew`, etc.) individually as well.

### Separable modules

Subdirectories (e.g., `hawk/`) are self-contained modules with their own Makefile. They must work standalone via `make -C <module>` so they can be shared with or extracted for others independently of the personal dotfiles.

### No secrets or sensitive data in plaintext

Files that contain personally identifiable information (emails, internal URLs, employee names) or secrets (API keys, tokens, passwords) must never be committed in plaintext.

**Resolution strategies:**

1. **Password-protected zip** (`zip -e`) — for exported data files that contain PII or internal URLs but aren't secrets per se (e.g., `chrome_bookmarks.zip`). The Makefile provides paired targets for backup and restore (e.g., `chrome-backup` / `chrome`). The plaintext file is gitignored; only the encrypted zip is committed.

2. **App-native encryption** — for tools that support encrypted export natively (e.g., Raycast's password-protected `.rayconfig`). Commit the encrypted export directly.

3. **Gitignored with template** — for files that are purely secrets with no shareable structure (e.g., `~/.zshrc.local`). Commit a `.example` template with empty placeholders; gitignore the real file via `*.local`.
