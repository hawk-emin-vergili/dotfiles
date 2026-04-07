# Hawk Module Spec

Design principles for the Hawk AI developer setup module.

## Role-based parametrization

Setup is grouped by role (backend, frontend, agentic). Each role group is independently runnable via `make backend`, `make frontend`, or `make agentic`. The interactive `make install` prompts for which roles to set up.

DevOps role is out of scope — to be added later by a devops expert.

## Source of truth

The full developer setup documentation lives on Confluence: [How to setup developer machine](https://hawkai.atlassian.net/wiki/spaces/HAW/pages/252837965). This module automates the macOS-specific subset.

## What this module does NOT handle

- `/etc/hosts` entries — the `testing` project handles these automatically for locally running services.
- FileVault, VPN certificates, security software — manual steps documented in README.md.
- IDE-specific configuration — handled per-project.

## Self-contained

This module must work standalone without the parent dotfiles repo. A new developer can run `make install` (or `make backend` / `make frontend`) directly from this directory.

Brew packages that overlap with the personal dotfiles Brewfile are intentionally duplicated here so colleagues get a complete setup without needing the personal dotfiles.
