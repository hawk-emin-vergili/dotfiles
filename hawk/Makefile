HAWK_DIR := $(shell pwd)
HOME     := $(shell echo $$HOME)

.PHONY: install backend frontend brew-backend brew-frontend brew-agentic gradle eks sdkman node pnpm agentic claude-plugin gemini-plugin help

define confirm
	@printf "\n>>> $(1) [y/N] " && read ans && [ "$$ans" = "y" ] || { echo "skipped"; false; }
endef

install: ## Run Hawk developer setup interactively
	@echo "=== Hawk AI developer setup ==="
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew not found. Install from https://brew.sh"; exit 1; }
	$(call confirm,Backend setup?)  && $(MAKE) --no-print-directory backend  || true
	$(call confirm,Frontend setup?) && $(MAKE) --no-print-directory frontend || true
	$(call confirm,Agentic tools setup (Gemini CLI)?) && $(MAKE) --no-print-directory agentic || true
	@echo "\n=== done ==="

backend: brew-backend gradle eks sdkman ## Install all backend dependencies

frontend: brew-frontend node pnpm ## Install all frontend dependencies

brew-backend: ## Install backend Homebrew packages
	@command -v brew >/dev/null || { echo "Homebrew not found. Install from https://brew.sh"; exit 1; }
	brew bundle --file=$(HAWK_DIR)/Brewfile.backend

brew-frontend: ## Install frontend Homebrew packages
	@command -v brew >/dev/null || { echo "Homebrew not found. Install from https://brew.sh"; exit 1; }
	brew bundle --file=$(HAWK_DIR)/Brewfile.frontend

gradle: ## Set up ~/.gradle/gradle.properties
	@if [ -f "$(HOME)/.gradle/gradle.properties" ]; then \
		echo "skip gradle.properties (already exists)"; \
	else \
		mkdir -p "$(HOME)/.gradle"; \
		cp "$(HAWK_DIR)/gradle.properties.example" "$(HOME)/.gradle/gradle.properties"; \
		echo "copied — edit ~/.gradle/gradle.properties to set artifactory_password"; \
	fi

eks: ## Configure kubectl for hawkai-dev-cluster
	@if ! command -v aws >/dev/null 2>&1; then \
		echo "skip eks (awscli not installed — run make brew-backend first)"; \
	elif [ ! -f "$(HOME)/.aws/credentials" ] && [ -z "$$AWS_ACCESS_KEY_ID" ]; then \
		echo "skip eks (no AWS credentials — run 'aws configure' first)"; \
	elif kubectl config get-contexts hawkai-dev-cluster >/dev/null 2>&1; then \
		echo "skip eks (context already exists)"; \
	else \
		aws eks --region eu-central-1 update-kubeconfig --name hawkai-dev-cluster; \
	fi

sdkman: ## Install SDKMAN for Java version management
	@if [ -d "$(HOME)/.sdkman" ]; then \
		echo "skip sdkman (already installed)"; \
	else \
		curl -s "https://get.sdkman.io" | bash; \
		echo "done — restart your shell or run: source ~/.sdkman/bin/sdkman-init.sh"; \
	fi

node: ## Install Node 22 via NVM
	@export NVM_DIR="$(HOME)/.nvm"; \
	if [ ! -s "$$NVM_DIR/nvm.sh" ]; then \
		echo "skip node (nvm not installed — run make brew-frontend first)"; \
	elif . "$$NVM_DIR/nvm.sh" && nvm ls 22 >/dev/null 2>&1; then \
		echo "skip node 22 (already installed)"; \
	else \
		. "$$NVM_DIR/nvm.sh" && nvm install 22; \
	fi

pnpm: ## Install pnpm globally via npm
	@if command -v pnpm >/dev/null 2>&1; then \
		echo "skip pnpm (already installed)"; \
	else \
		npm install -g pnpm@10; \
	fi

brew-agentic: ## Install agentic Homebrew packages (Gemini CLI)
	@command -v brew >/dev/null || { echo "Homebrew not found. Install from https://brew.sh"; exit 1; }
	brew bundle --file=$(HAWK_DIR)/Brewfile.agentic

agentic: brew-agentic claude-plugin gemini-plugin ## Set up agentic dev tools (Claude Code plugin, Gemini extension)
	@echo ""
	@echo "Claude Code: install manually from https://docs.anthropic.com/en/docs/claude-code/overview"
	@echo "             then follow the Hawk wiki: https://hawkai.atlassian.net/wiki/x/BoCFMwE"
	@echo ""
	@echo "Gemini CLI:  for API key setup, see https://hawkai.atlassian.net/wiki/x/FYAHOAE"

claude-plugin: ## Register agentic-productivity-toolkit marketplace in Claude Code
	@if [ ! -f $(HOME)/.claude/settings.json ]; then \
		echo "skip (~/.claude/settings.json not found — install Claude Code first)"; \
	elif ! command -v jq >/dev/null 2>&1; then \
		echo "skip (jq not found — install jq first)"; \
	else \
		tmp=$$(mktemp); \
		jq -s '.[0] * .[1]' $(HOME)/.claude/settings.json $(HAWK_DIR)/claude_settings.json > "$$tmp"; \
		mv "$$tmp" $(HOME)/.claude/settings.json; \
		echo "registered agentic-productivity-toolkit marketplace in ~/.claude/settings.json"; \
	fi

gemini-plugin: ## Install agentic-productivity-toolkit extension for Gemini CLI
	@if ! command -v gemini >/dev/null 2>&1; then \
		echo "skip (gemini not found — run make brew-agentic first)"; \
	else \
		gemini extensions install https://github.com/hawk-ai-aml/agentic-productivity-toolkit.git --ref=master --auto-update; \
		echo "installed agentic-productivity-toolkit extension for Gemini CLI"; \
	fi

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  make %-15s %s\n", $$1, $$2}'
