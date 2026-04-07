# ── Completions ──────────────────────────────────────────────────

autoload -Uz compinit && compinit

# ── Aliases ──────────────────────────────────────────────────────

alias la='ls -lAh'
alias claude-dev='claude --plugin-dir ~/Projects/agentic-productivity-toolkit'

# ── Custom Functions ─────────────────────────────────────────────

merge2dev() {
    git branch -D develop
    git fetch origin develop
    git switch -t origin/develop
    git merge "${1}"
}
compdef _git merge2dev=git-merge

gmaster() {
    git checkout master
    git pull origin master
}

greview() {
    git checkout master
    git branch -D "${1}"
    git fetch origin "${1}"
    git switch -t origin/"${1}"
}
compdef _git greview=git-merge

# ── NVM ──────────────────────────────────────────────────────────

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ── SDKMAN ────────────────────────────────────────────────────────

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export PATH="$HOME/.local/bin:$PATH"

# ── Local overrides (secrets, machine-specific) ──────────────────

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
