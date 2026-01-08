#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Bootstrap a Manjaro desktop:
#  • Single pacman upgrade
#  • Needed-only installs
#  • Idempotent zshrc edits (with backups)
#  • AUR helper auto-detection
#  • Non-interactive SSH-agent setup (env override)
#  • Local dotfile installs (including Neovim via ./vim/install.sh)
# -----------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.zshrc"

# Ensure pacman + sudo exist
for cmd in pacman sudo; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' command not found. Aborting."
    exit 1
  fi
done

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
  echo ">> Applying Manjaro Zsh configuration..."
  add_to_config 'source /usr/share/zsh/manjaro-zsh-config' "Manjaro Zsh config"
  add_to_config 'source /usr/share/zsh/manjaro-zsh-prompt' "Manjaro Zsh prompt"
  add_to_config 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' "Zsh syntax highlighting"
  add_to_config 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' "Zsh autosuggestions"
}
apply_zsh_configs

# -----------------------------------------------------------------------------
# 2) SSH-agent setup (non-interactive if SSH_KEY_PATH is set)
# -----------------------------------------------------------------------------
if ! grep -qF 'ssh-agent -s' "$CONFIG_FILE"; then
  echo ">> Setting up ssh-agent in your zshrc..."
  add_to_config 'eval "$(ssh-agent -s)"' "SSH agent init"

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
# 4) Package groups (Manjaro/Arch names)
# -----------------------------------------------------------------------------
declare -A groups=(
  # NOTE: openssh provides the `ssh` command; python provides python3
  [core]="openssh curl git python valgrind base-devel"
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
echo ">> Updating system & installing packages..."
sudo pacman -Syu --noconfirm

for grp in "${!groups[@]}"; do
  echo "  • [pacman] ${grp}: ${groups[$grp]}"
  sudo pacman -S --needed --noconfirm ${groups[$grp]}
done

if [[ -n "$aur_helper" ]]; then
  echo "  • [AUR] Installing via $aur_helper: ${aur_pkgs[*]}"
  $aur_helper -S --needed --noconfirm "${aur_pkgs[@]}"
else
  echo "NOTE: No AUR helper found; skipping AUR packages."
fi

# -----------------------------------------------------------------------------
# 6) Neovim setup (delegated to ./vim/install.sh)
# -----------------------------------------------------------------------------
NVIM_INSTALLER="$DOTFILES_DIR/vim/install.sh"
if [[ -f "$NVIM_INSTALLER" ]]; then
  echo ">> Running Neovim installer: $NVIM_INSTALLER"
  bash "$NVIM_INSTALLER"
else
  echo "WARNING: Neovim installer not found at $NVIM_INSTALLER; skipping."
fi

# -----------------------------------------------------------------------------
# 7) Konsole themes (copy any .profile/.colorscheme you ship)
# -----------------------------------------------------------------------------
KONSOLE_DIR="$HOME/.local/share/konsole"
mkdir -p "$KONSOLE_DIR"

if [[ -d "$DOTFILES_DIR/konsole" ]]; then
  shopt -s nullglob
  konsole_files=("$DOTFILES_DIR"/konsole/*.profile "$DOTFILES_DIR"/konsole/*.colorscheme)
  shopt -u nullglob

  if (( ${#konsole_files[@]} )); then
    echo ">> Installing Konsole profiles/colorschemes to $KONSOLE_DIR"
    for src in "${konsole_files[@]}"; do
      cp -i "$src" "$KONSOLE_DIR/$(basename "$src")"
    done
  else
    echo "NOTE: No Konsole .profile/.colorscheme files found in $DOTFILES_DIR/konsole; skipping."
  fi
else
  echo "NOTE: $DOTFILES_DIR/konsole directory not found; skipping Konsole theme install."
fi

echo "Setup complete."

