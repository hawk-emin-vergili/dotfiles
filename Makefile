DOTFILES := $(shell pwd)
HOME     := $(shell echo $$HOME)

LINKS := \
	zshrc:.zshrc \
	zprofile:.zprofile \
	gitconfig:.gitconfig \
	Brewfile:.Brewfile

.PHONY: install link unlink brew claude macos ssh raycast obsidian skills chrome chrome-backup hawk help

define confirm
	@printf "\n>>> $(1) [y/N] " && read ans && [ "$$ans" = "y" ] || { echo "skipped"; false; }
endef

install: ## Run full setup interactively
	@echo "=== dotfiles setup ==="
	@xcode-select -p >/dev/null 2>&1 || { echo "Xcode Command Line Tools not found. Run: xcode-select --install"; exit 1; }
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew not found. Install from https://brew.sh"; exit 1; }
	$(call confirm,Symlink dotfiles into ~?)        && $(MAKE) --no-print-directory link    || true
	$(call confirm,Install Homebrew packages?)      && $(MAKE) --no-print-directory brew    || true
	$(call confirm,Copy zshrc.local.example to ~/.zshrc.local?) && \
		if [ -e "$(HOME)/.zshrc.local" ]; then \
			echo "skip (already exists)"; \
		else \
			cp "$(DOTFILES)/zshrc.local.example" "$(HOME)/.zshrc.local"; \
			echo "copied — edit ~/.zshrc.local to fill in secrets"; \
		fi || true
	$(call confirm,Merge personal Claude Code settings?) && $(MAKE) --no-print-directory claude || true
	$(call confirm,Set up SSH config for GitHub?)    && $(MAKE) --no-print-directory ssh     || true
	$(call confirm,Apply macOS defaults?)           && $(MAKE) --no-print-directory macos   || true
	$(call confirm,Import Raycast settings?)       && $(MAKE) --no-print-directory raycast || true
	$(call confirm,Symlink Obsidian vault settings?) && $(MAKE) --no-print-directory obsidian || true
	$(call confirm,Restore Chrome bookmarks?)       && $(MAKE) --no-print-directory chrome  || true
	$(call confirm,Clone and link agent skills?)   && $(MAKE) --no-print-directory skills  || true
	$(call confirm,Run Hawk AI developer setup?)   && $(MAKE) --no-print-directory hawk    || true
	@echo "\n=== done ==="

claude: ## Merge personal Claude Code plugin settings
	@if [ ! -f $(HOME)/.claude/settings.json ]; then \
		echo "skip (~/.claude/settings.json not found — install Claude Code first)"; \
	elif ! command -v jq >/dev/null 2>&1; then \
		echo "skip (jq not found — run 'make brew' first)"; \
	else \
		tmp=$$(mktemp); \
		jq -s '.[0] * .[1]' $(HOME)/.claude/settings.json $(DOTFILES)/claude_settings.json > "$$tmp"; \
		mv "$$tmp" $(HOME)/.claude/settings.json; \
		echo "merged personal plugin settings into ~/.claude/settings.json"; \
	fi

ssh: ## Add GitHub SSH config via Include directive
	@mkdir -p $(HOME)/.ssh && chmod 700 $(HOME)/.ssh
	@if [ -f $(HOME)/.ssh/config ] && grep -qF 'Include $(DOTFILES)/ssh_config_github' $(HOME)/.ssh/config; then \
		echo "skip (already included)"; \
	else \
		printf 'Include $(DOTFILES)/ssh_config_github\n\n' | cat - $(HOME)/.ssh/config 2>/dev/null > $(HOME)/.ssh/config.tmp \
			&& mv $(HOME)/.ssh/config.tmp $(HOME)/.ssh/config \
			|| printf 'Include $(DOTFILES)/ssh_config_github\n' > $(HOME)/.ssh/config; \
		chmod 600 $(HOME)/.ssh/config; \
		echo "added Include directive to ~/.ssh/config"; \
	fi
	@if [ ! -f $(HOME)/.ssh/github_id_ed25519 ]; then \
		echo "note: no GitHub key found — run: ssh-keygen -t ed25519 -f ~/.ssh/github_id_ed25519"; \
	fi

macos: ## Apply macOS defaults (Dock, keyboard, screenshots)
	@bash $(DOTFILES)/macos

raycast: ## Import Raycast settings from export file
	@if [ ! -f $(DOTFILES)/Raycast.rayconfig ]; then \
		echo "Raycast.rayconfig not found in dotfiles."; \
		echo "Export your settings: Raycast → Settings → Advanced → Export"; \
		echo "Save the file as $(DOTFILES)/Raycast.rayconfig"; \
	else \
		echo "To import: open Raycast → Settings → Advanced → Import"; \
		echo "Select: $(DOTFILES)/Raycast.rayconfig"; \
		open $(DOTFILES)/Raycast.rayconfig; \
	fi

OBSIDIAN_VAULT := $(HOME)/Documents/Obsidian Vault
OBSIDIAN_FILES := app.json appearance.json core-plugins.json graph.json

obsidian: ## Symlink Obsidian vault settings
	@if [ ! -d "$(OBSIDIAN_VAULT)/.obsidian" ]; then \
		echo "skip (vault not found at $(OBSIDIAN_VAULT) — open Obsidian and create it first)"; \
	else \
		for f in $(OBSIDIAN_FILES); do \
			if [ -L "$(OBSIDIAN_VAULT)/.obsidian/$$f" ]; then \
				echo "skip $$f (already linked)"; \
			elif [ -e "$(OBSIDIAN_VAULT)/.obsidian/$$f" ]; then \
				mv "$(OBSIDIAN_VAULT)/.obsidian/$$f" "$(OBSIDIAN_VAULT)/.obsidian/$$f.bak"; \
				ln -s "$(DOTFILES)/obsidian/$$f" "$(OBSIDIAN_VAULT)/.obsidian/$$f"; \
				echo "link $$f (backed up original)"; \
			else \
				ln -s "$(DOTFILES)/obsidian/$$f" "$(OBSIDIAN_VAULT)/.obsidian/$$f"; \
				echo "link $$f"; \
			fi; \
		done; \
	fi

CHROME_BOOKMARKS_ZIP := $(DOTFILES)/chrome_bookmarks.zip
CHROME_DIR := $(HOME)/Library/Application Support/Google/Chrome

chrome: ## Restore Chrome bookmarks from encrypted backup
	@if [ ! -f "$(CHROME_BOOKMARKS_ZIP)" ]; then \
		echo "skip (chrome_bookmarks.zip not found in dotfiles)"; \
	elif [ ! -d "$(CHROME_DIR)" ]; then \
		echo "skip (Chrome not found — install Chrome first)"; \
	else \
		profile_dir=""; \
		for d in "$(CHROME_DIR)/Default" "$(CHROME_DIR)"/Profile\ *; do \
			if [ -d "$$d" ]; then profile_dir="$$d"; break; fi; \
		done; \
		if [ -z "$$profile_dir" ]; then \
			echo "skip (no Chrome profile found — open Chrome first)"; \
		else \
			dst="$$profile_dir/Bookmarks"; \
			if [ -f "$$dst" ]; then \
				cp "$$dst" "$$dst.bak"; \
				echo "backed up existing bookmarks"; \
			fi; \
			unzip -o -P "" "$(CHROME_BOOKMARKS_ZIP)" -d /tmp >/dev/null 2>&1 \
				|| unzip -o "$(CHROME_BOOKMARKS_ZIP)" -d /tmp; \
			cp /tmp/chrome_bookmarks.json "$$dst"; \
			rm -f /tmp/chrome_bookmarks.json; \
			echo "restored Chrome bookmarks to $$profile_dir (restart Chrome to see changes)"; \
		fi; \
	fi

chrome-backup: ## Backup Chrome bookmarks to encrypted zip
	@if [ ! -d "$(CHROME_DIR)" ]; then \
		echo "skip (Chrome not found)"; \
	else \
		profile_dir=""; \
		for d in "$(CHROME_DIR)/Default" "$(CHROME_DIR)"/Profile\ *; do \
			if [ -d "$$d" ]; then profile_dir="$$d"; break; fi; \
		done; \
		if [ -z "$$profile_dir" ]; then \
			echo "skip (no Chrome profile found)"; \
		elif [ ! -f "$$profile_dir/Bookmarks" ]; then \
			echo "skip (no Bookmarks file in $$profile_dir)"; \
		else \
			cp "$$profile_dir/Bookmarks" /tmp/chrome_bookmarks.json; \
			rm -f "$(CHROME_BOOKMARKS_ZIP)"; \
			cd /tmp && zip -e "$(CHROME_BOOKMARKS_ZIP)" chrome_bookmarks.json; \
			rm -f /tmp/chrome_bookmarks.json; \
			echo "encrypted backup saved to chrome_bookmarks.zip"; \
		fi; \
	fi

SKILLS_REPO := git@github.com:hawk-emin-vergili/agent-skills.git
SKILLS_DIR  := $(HOME)/.agents/skills
SKILLS_LINK := $(HOME)/.claude/skills

skills: ## Clone agent skills repo and symlink into Claude Code
	@if [ -d "$(SKILLS_DIR)/.git" ]; then \
		echo "skip skills clone (already exists at $(SKILLS_DIR))"; \
	else \
		mkdir -p "$(HOME)/.agents"; \
		git clone $(SKILLS_REPO) "$(SKILLS_DIR)"; \
		echo "cloned agent-skills to $(SKILLS_DIR)"; \
	fi
	@if [ -L "$(SKILLS_LINK)" ]; then \
		echo "skip skills symlink (already linked)"; \
	elif [ -e "$(SKILLS_LINK)" ]; then \
		echo "warn: $(SKILLS_LINK) exists but is not a symlink — skipping"; \
	else \
		mkdir -p "$(HOME)/.claude"; \
		ln -s "$(SKILLS_DIR)" "$(SKILLS_LINK)"; \
		echo "linked $(SKILLS_LINK) -> $(SKILLS_DIR)"; \
	fi

hawk: ## Run Hawk AI developer setup
	@$(MAKE) -C $(DOTFILES)/hawk install

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'

link: ## Symlink dotfiles into ~
	@for pair in $(LINKS); do \
		src=$${pair%%:*}; dst=$${pair##*:}; \
		if [ -L "$(HOME)/$$dst" ]; then \
			echo "skip $$dst (already linked)"; \
		elif [ -e "$(HOME)/$$dst" ]; then \
			echo "back $$dst -> $$dst.bak"; \
			mv "$(HOME)/$$dst" "$(HOME)/$$dst.bak"; \
			ln -s "$(DOTFILES)/$$src" "$(HOME)/$$dst"; \
			echo "link $$dst"; \
		else \
			ln -s "$(DOTFILES)/$$src" "$(HOME)/$$dst"; \
			echo "link $$dst"; \
		fi; \
	done

unlink: ## Remove symlinks (restore .bak if present)
	@for pair in $(LINKS); do \
		dst=$${pair##*:}; \
		if [ -L "$(HOME)/$$dst" ]; then \
			rm "$(HOME)/$$dst"; \
			echo "rm   $$dst"; \
			if [ -e "$(HOME)/$$dst.bak" ]; then \
				mv "$(HOME)/$$dst.bak" "$(HOME)/$$dst"; \
				echo "restore $$dst from backup"; \
			fi; \
		fi; \
	done

brew: ## Install Homebrew packages from Brewfile
	@command -v brew >/dev/null || { echo "Homebrew not found. Install from https://brew.sh"; exit 1; }
	brew bundle --file=$(DOTFILES)/Brewfile
