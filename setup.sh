#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Bootstrap a Manjaro desktop:
#  • Single pacman upgrade
#  • Needed‑only installs
#  • Idempotent zshrc edits (with backups)
#  • AUR helper auto‑detection
#  • Non‑interactive SSH‐agent setup (env override)
#  • Local dotfile & Konsole theme installs
# -----------------------------------------------------------------------------

# Ensure pacman + sudo exist
for cmd in pacman sudo; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' command not found. Aborting."
    exit 1
  fi
done

CONFIG_FILE="$HOME/.zshrc"

# Backup existing zshrc once
if [[ -f "$CONFIG_FILE" ]]; then
  cp -n "$CONFIG_FILE" "${CONFIG_FILE}.bak-$(date +%Y%m%d%H%M%S)"
fi

# Ensure zshrc exists
touch "$CONFIG_FILE"

# -----------------------------------------------------------------------------
# Helpers for idempotent appends
# -----------------------------------------------------------------------------
append_if_missing() {
  local line="$1" file="$2"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

add_to_config() {
  local content="$1" desc="$2"
  if append_if_missing "$content" "$CONFIG_FILE"; then
    echo "✔ $desc added to $CONFIG_FILE"
  fi
}

# -----------------------------------------------------------------------------
# 1) Apply Manjaro Zsh configs, prompt & plugins
# -----------------------------------------------------------------------------
apply_zsh_configs() {
  echo ">> Applying Manjaro Zsh configuration…"
  add_to_config 'source /usr/share/zsh/manjaro-zsh-config'    "Manjaro Zsh config"
  add_to_config 'source /usr/share/zsh/manjaro-zsh-prompt'    "Manjaro Zsh prompt"
  add_to_config 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'  "Zsh syntax highlighting"
  add_to_config 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'          "Zsh autosuggestions"
}
apply_zsh_configs

# -----------------------------------------------------------------------------
# 2) SSH‑agent setup (non‑interactive if SSH_KEY_PATH is set)
# -----------------------------------------------------------------------------
if ! grep -qF 'ssh-agent -s' "$CONFIG_FILE"; then
  echo ">> Setting up ssh-agent in your zshrc…"
  add_to_config 'eval "$(ssh-agent -s)"' "SSH agent init"

  # Determine key path: env override or default
  SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_rsa}"
  if [[ -f "$SSH_KEY_PATH" ]]; then
    add_to_config "ssh-add $SSH_KEY_PATH" "SSH key addition"
  else
    echo "WARNING: SSH key not found at $SSH_KEY_PATH; skipping ssh-add."
  fi
fi

# -----------------------------------------------------------------------------
# 3) Detect AUR helper (yay or paru)
# -----------------------------------------------------------------------------
aur_helper=""
for helper in yay paru; do
  if command -v "$helper" &>/dev/null; then
    aur_helper="$helper"
    break
  fi
done

# -----------------------------------------------------------------------------
# 4) Package groups
# -----------------------------------------------------------------------------
declare -A groups=(
  [core]="ssh curl git vim python3 valgrind base-devel"
  [build]="gcc jdk-openjdk cmake make"
  [dev]="docker python-virtualenv"
  [apps]="vlc"
  [terminal]="tmux htop"
  [search]="screenfetch"
)

aur_pkgs=(
  postman-bin
  mattermost-desktop
  teams
  google-chrome
  obsidian
)

# -----------------------------------------------------------------------------
# 5) System upgrade + installs
# -----------------------------------------------------------------------------
echo ">> Updating system & installing packages…"
sudo pacman -Syu --noconfirm

# Pacman groups
for grp in "${!groups[@]}"; do
  echo "  • [pacman] ${grp}: ${groups[$grp]}"
  sudo pacman -S --needed --noconfirm ${groups[$grp]}
done

# AUR packages
if [[ -n "$aur_helper" ]]; then
  echo "  • [AUR] Installing via $aur_helper: ${aur_pkgs[*]}"
  $aur_helper -S --needed --noconfirm "${aur_pkgs[@]}"
else
  echo "NOTE: No AUR helper found; skipping AUR packages."
fi

# -----------------------------------------------------------------------------
# 6) Copy local .vimrc if present in ./vim/
# -----------------------------------------------------------------------------
if [[ -f "./vim/.vimrc" ]]; then
  echo ">> Copying local .vimrc from ./vim to $HOME/.vimrc"
  cp -i "./vim/.vimrc" "$HOME/.vimrc"
fi

# -----------------------------------------------------------------------------
# 7) Install Dracula Konsole profile & colorscheme from ./konsole/
# -----------------------------------------------------------------------------
KONSOLE_DIR="$HOME/.local/share/konsole"
mkdir -p "$KONSOLE_DIR"

for file in dracula.profile dracula.colorscheme; do
  src="./konsole/$file"
  if [[ -f "$src" ]]; then
    echo ">> Installing $file from ./konsole to $KONSOLE_DIR"
    cp -i "$src" "$KONSOLE_DIR/$file"
  fi
done

add_to_config "source $KONSOLE_DIR/dracula.profile" "Dracula Konsole profile source"

echo "Setup complete."



