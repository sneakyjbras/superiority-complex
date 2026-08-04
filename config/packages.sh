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
  [dev]="docker python-virtualenv"
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

# Terminal AI coding CLIs. Deliberately just two:
#   • Claude Code  — native installer, self-updating.
#   • Antigravity  — Google's CLI (`agy`), self-updating via `agy update`.
# Both ship as standalone binaries under ~/.local/bin, so there is no npm/pipx
# package list here. modules/30-ai-cli.sh drives them.
#
# Removed on purpose (do not re-add without a reason): @openai/codex,
# @google/gemini-cli (superseded by Antigravity), aider-chat, opencode.
#
# NOT INSTALLED, also on purpose: visual-studio-code-bin and cursor-bin.
# Neovim is the editor; see "No IDE, on purpose" in the README. GitHub Copilot
# is kept in Neovim only (copilot.vim), not as an IDE extension.

# Extra packages Neovim needs (installed by modules/40-neovim.sh).
# tree-sitter-cli: REQUIRED by nvim-treesitter's `main` branch, which shells out
#   to the `tree-sitter` binary to generate parsers (the `tree-sitter` package
#   alone is only the library and does NOT provide that binary).
# make + gcc: compile the generated parsers.
declare -ga NVIM_PKGS=(
  neovim git curl ripgrep fd wl-clipboard xclip make gcc tree-sitter-cli
)

# i3 window manager + the desktop pieces Plasma used to provide (installed by
# modules/60-i3.sh). i3 is X11-only, hence the xorg entries.
#   rofi        launcher / window switcher      picom    compositor
#   dunst       notifications                   feh      wallpaper
#   i3lock      screen locker                   xss-lock lock on idle/suspend
#   maim+xclip  screenshots to clipboard        nm-applet/pavucontrol  tray
#   lxappearance  GTK theming without Plasma's settings app
declare -ga I3_PKGS=(
  i3-wm i3status i3lock
  rofi picom dunst feh xss-lock maim
  xorg-server xorg-xinit xorg-xrandr xorg-xsetroot
  network-manager-applet pavucontrol lxappearance
  otf-font-awesome
)
