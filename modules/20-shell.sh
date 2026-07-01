#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Shell setup: Manjaro Zsh config/prompt/plugins, ssh-agent init, and PATH.
# All edits are idempotent (safe to re-run). A one-time ~/.zshrc backup is kept.
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_DIR/lib/common.sh"

ZSHRC="$HOME/.zshrc"

# One-time backup of an existing zshrc.
if [[ -f "$ZSHRC" ]]; then
  cp -n "$ZSHRC" "${ZSHRC}.bak-$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
fi
touch "$ZSHRC"

# --- 1) Manjaro Zsh configuration -------------------------------------------
log_step "Applying Manjaro Zsh configuration"
add_to_config 'source /usr/share/zsh/manjaro-zsh-config' "Manjaro Zsh config"
add_to_config 'source /usr/share/zsh/manjaro-zsh-prompt' "Manjaro Zsh prompt"
add_to_config 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' "Zsh syntax highlighting"
add_to_config 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' "Zsh autosuggestions"

# --- 2) SSH agent ------------------------------------------------------------
# Non-interactive if SSH_KEY_PATH is set; defaults to ~/.ssh/id_rsa.
if ! grep -qF 'ssh-agent -s' "$ZSHRC"; then
  log_step "Setting up ssh-agent in $ZSHRC"
  add_to_config 'eval "$(ssh-agent -s)"' "SSH agent init"

  SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_rsa}"
  if [[ -f "$SSH_KEY_PATH" ]]; then
    add_to_config "ssh-add $SSH_KEY_PATH" "SSH key addition"
  else
    log_warn "SSH key not found at $SSH_KEY_PATH; skipping ssh-add."
  fi
fi

# --- 3) PATH -----------------------------------------------------------------
log_step "Ensuring ~/.local/bin is on PATH"
add_path_to_shells 'export PATH="$HOME/.local/bin:$PATH"'
