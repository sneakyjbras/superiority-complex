#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Package manifest — edit this file to change what gets installed.
# It contains DATA ONLY (no logic); it is sourced by the install modules.
# Package names use Arch/Manjaro naming.
# -----------------------------------------------------------------------------

# Official-repo packages, grouped by purpose. Installed with `pacman -S --needed`.
# NOTE: openssh provides the `ssh` command; python provides python3.
declare -gA PACMAN_GROUPS=(
  [core]="openssh curl git python nodejs npm valgrind base-devel"
  [build]="gcc jdk-openjdk cmake make"
  [dev]="docker python-virtualenv python-pipx"
  [apps]="vlc"
  [terminal]="tmux htop"
  [search]="screenfetch"
)

# AUR packages. Installed with an AUR helper (yay/paru); yay is auto-bootstrapped
# by modules/10-packages.sh if no helper is present.
declare -ga AUR_PKGS=(
  postman-bin
  mattermost-desktop
  teams
  google-chrome
  obsidian
)

# Terminal AI coding CLIs installed via npm (global). Claude Code is installed
# separately via its native installer in modules/30-ai-cli.sh.
declare -ga NPM_AI_CLIS=(
  @openai/codex
  @google/gemini-cli
)

# Terminal AI coding CLIs installed via pipx (isolated Python venvs).
# Installed by modules/30-ai-cli.sh.
declare -ga PIPX_AI_CLIS=(
  aider-chat
)

# Extra packages Neovim needs (installed by modules/40-neovim.sh).
# make + gcc: compile treesitter parsers and run the avante.nvim `make` build.
declare -ga NVIM_PKGS=(
  neovim git curl ripgrep fd wl-clipboard xclip make gcc
)
