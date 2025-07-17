#!/usr/bin/env bash

set -euo pipefail

# Ensure pacman is available (Arch-based)
if ! command -v pacman >/dev/null 2>&1; then
  echo "Unsupported system: pacman not found."
  exit 1
fi

CONFIG_FILE="$HOME/.zshrc"

# Detect AUR helper
aur_helper=""
for helper in yay paru; do
  if command -v "$helper" >/dev/null 2>&1; then
    aur_helper="$helper"
    break
  fi
done

# Helper: append line if missing
append_if_missing() {
  local line="$1"
  local file="$2"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# Zsh configuration (common plus Manjaro-specific)
zsh_configs=(
  # Colourful aliases
  "alias ls='ls --color=auto'"
  "alias grep='grep --color=auto'"
  "alias egrep='egrep --color=auto'"
  "alias fgrep='fgrep --color=auto'"
  "alias tail='tail --color=always'"
  "alias dmesg='dmesg --color=always'"
  # Load system dircolors for default bold directories
  "eval \"\$(dircolors -b /etc/DIR_COLORS)\""
  # Prompt style
  "export PS1='%F{green}%n@%m %F{blue}%~%f $ '"
)
if [[ -f /etc/manjaro-release ]]; then
  zsh_configs+=(
    "source /usr/share/zsh/manjaro-zsh-config"
    "source /usr/share/zsh/manjaro-zsh-prompt"
    "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  )
fi

# Apply zsh configs
for line in "${zsh_configs[@]}"; do
  append_if_missing "$line" "$CONFIG_FILE"
done

# SSH agent setup
if ! grep -qF "ssh-agent -s" "$CONFIG_FILE"; then
  append_if_missing "eval \"\$(ssh-agent -s)\"" "$CONFIG_FILE"
  read -rp "Enter SSH key path [~/.ssh/id_rsa]: " ssh_key_path
  ssh_key_path=${ssh_key_path:-$HOME/.ssh/id_rsa}
  if [[ -f "$ssh_key_path" ]]; then
    append_if_missing "ssh-add $ssh_key_path" "$CONFIG_FILE"
  else
    echo "WARNING: SSH key not found at $ssh_key_path."
  fi
fi

# Package groups
declare -A groups=(
  [core]="ssh curl git vim python3 valgrind base-devel"
  [build]="gcc jdk-openjdk cmake make"
  [dev]="docker python-virtualenv"
  [apps]="vlc zoom spotify"
  [terminal]="tmux htop"
  [search]="screenfetch"
)
# AUR-only packages
aur_pkgs=(
  postman-bin
  mattermost-desktop
  teams
  google-chrome
  obsidian
)
if [[ -n "$aur_helper" ]]; then
  groups[aur]="${aur_pkgs[*]}"
fi

# Install functions
default_install() {
  local pkg="$1" group="$2"
  if [[ "$group" == "aur" ]]; then
    $aur_helper -S --noconfirm "$pkg"
  else
    sudo pacman -S --noconfirm "$pkg"
  fi
}

install_group() {
  local name="$1"
  local pkgs=( ${groups[$name]} )
  local missing=()
  for pkg in "${pkgs[@]}"; do
    command -v "${pkg%%=*}" >/dev/null 2>&1 || missing+=("$pkg")
  done
  [[ ${#missing[@]} -eq 0 ]] && return
  echo "Installing [$name]: ${missing[*]}"
  sudo pacman -Syu --noconfirm
  for pkg in "${missing[@]}"; do
    default_install "$pkg" "$name"
  done
}

# Run installs
for grp in core build dev apps terminal search aur; do
  install_group "$grp"
done

# Copy local .vimrc
if [[ -f "./.vimrc" ]]; then
  echo "Copying .vimrc to $HOME/.vimrc..."
  cp -i "./.vimrc" "$HOME/.vimrc"
fi

# Install Dracula Konsole profile and colorscheme
KONSOLE_DIR="$HOME/.local/share/konsole"
mkdir -p "$KONSOLE_DIR"
for file in dracula.profile dracula.colorscheme; do
  if [[ -f "./$file" ]]; then
    echo "Installing $file to $KONSOLE_DIR..."
    cp -i "./$file" "$KONSOLE_DIR/$file"
  fi
done

# Source dracula.profile in zshrc if needed
if ! grep -qF "source $KONSOLE_DIR/dracula.profile" "$CONFIG_FILE"; then
  append_if_missing "source $KONSOLE_DIR/dracula.profile" "$CONFIG_FILE"
fi

echo "Setup complete."

