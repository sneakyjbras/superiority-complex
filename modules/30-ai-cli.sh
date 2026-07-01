#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Terminal AI coding CLIs: Claude Code (native installer) plus npm-based CLIs
# (Codex, Gemini). npm is configured with a user-local prefix so no sudo/root
# global installs are needed. List of npm CLIs lives in config/packages.sh.
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/config/packages.sh"

log_step "Installing terminal AI coding CLIs"

# User-local npm prefix + PATH (avoids root-owned global installs).
npm_prefix="$HOME/.local/npm"
mkdir -p "$npm_prefix"
add_path_to_shells 'export PATH="$HOME/.local/bin:$PATH"'
add_path_to_shells 'export PATH="$HOME/.local/npm/bin:$PATH"'
export PATH="$HOME/.local/bin:$HOME/.local/npm/bin:$PATH"

# --- Claude Code (native CLI) ------------------------------------------------
if has_cmd claude; then
  log_ok "Claude Code already installed."
else
  log_info "Installing Claude Code native CLI..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    log_ok "Claude Code installed."
  else
    log_warn "Claude Code install failed."
  fi
fi

# --- npm-based CLIs ----------------------------------------------------------
if has_cmd npm; then
  npm config set prefix "$npm_prefix" >/dev/null 2>&1 || true
  if [[ ${#NPM_AI_CLIS[@]} -gt 0 ]]; then
    log_info "Installing npm CLIs: ${NPM_AI_CLIS[*]}"
    npm install -g "${NPM_AI_CLIS[@]}" || log_warn "Some npm CLIs failed to install."
  fi
else
  log_warn "npm not found; skipping npm CLIs: ${NPM_AI_CLIS[*]:-none}"
fi
