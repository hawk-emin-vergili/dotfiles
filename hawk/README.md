# Hawk AI Developer Setup (macOS)

Automates the macOS developer machine setup for Hawk AI. See the full setup guide on [Confluence](https://hawkai.atlassian.net/wiki/spaces/HAW/pages/252837965).

## Quick start

```bash
make install       # interactive — prompts for backend, frontend, and agentic
```

Or run a specific role directly:

```bash
make backend       # all backend steps
make frontend      # all frontend steps
make agentic       # agentic dev tools (Claude Code + Gemini CLI)
make help          # list all targets
```

Individual steps can also be run standalone (e.g., `make sdkman`, `make eks`).

## What gets installed

### Backend (`make backend`)
- **Homebrew packages**: awscli, helm, jq, k9s, kubectl, kustomize, Docker Desktop, Tunnelblick
- **Gradle properties**: Artifactory credentials template at `~/.gradle/gradle.properties`
- **EKS kubeconfig**: kubectl context for `hawkai-dev-cluster`
- **SDKMAN**: Java version manager (install Java versions with `sdk install java 17-open`)

### Frontend (`make frontend`)
- **Homebrew packages**: nvm
- **Node.js 22**: installed via NVM
- **pnpm 10**: installed globally via npm

### Agentic (`make agentic`)
- **Homebrew packages**: gemini-cli
- **Claude Code**: install manually from [docs](https://docs.anthropic.com/en/docs/claude-code/overview), then this target merges Hawk plugin settings into `~/.claude/settings.json` (registers agentic-productivity-toolkit marketplace + enables plugin)
- **Gemini CLI**: installs the [agentic-productivity-toolkit](https://github.com/hawk-ai-aml/agentic-productivity-toolkit) extension via `gemini extensions install`

## Manual steps

These cannot be automated and must be done by hand:

- [ ] [Enable FileVault full disk encryption](https://hawkai.atlassian.net/wiki/spaces/HAW/pages/252837965/How+to+setup+developer+machine#For-Apple-MacOS---Filevault-Full-Disk-Encryption), save recovery key to Bitwarden, share with IT
- [ ] [Request security software](https://hawkai.atlassian.net/wiki/spaces/HAW/pages/252837965/How+to+setup+developer+machine#Windows%2C-Linux%2C-Apple-MacOS---Security-Software) installation from support-office-it@hawk.ai
- [ ] Request VPN certificate via [SRE Support](https://hawkai.atlassian.net/wiki/spaces/SRE/pages/3327426561) and import into Tunnelblick
- [ ] Request AWS account access (ask team lead, requires Personio permissions first)
- [ ] Set up [AWS switch script](https://hawkai.atlassian.net/wiki/spaces/SRE/pages/3437690881) for environment switching (dev/test/prod)
- [ ] Join Slack channels: #developers, #releasing, #team-pe, status/exception channels
- [ ] Fill in `~/.gradle/gradle.properties` with Artifactory password (ask a teammate)

## After setup

- **Backend**: clone [backend](https://github.com/hawk-ai-aml/backend), run `./gradlew build`
- **Frontend**: clone [case-manager](https://github.com/hawk-ai-aml/case-manager), run `nvm use && pnpm install && pnpm dev:cm`
