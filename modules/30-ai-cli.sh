#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Terminal AI coding CLIs. Two are kept, both standalone self-updating binaries
# living under ~/.local/bin (no npm globals, no pipx venvs, no sudo):
#   • Claude Code  — installed via its native installer.
#   • Antigravity  — Google's `agy` CLI; updates itself via `agy update`.
# Also links the versioned Claude Code config (config/claude) into ~/.claude.
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_DIR/lib/common.sh"

log_step "Installing terminal AI coding CLIs"

add_path_to_shells 'export PATH="$HOME/.local/bin:$PATH"'
export PATH="$HOME/.local/bin:$PATH"

# --- Claude Code (native CLI) ------------------------------------------------
if has_cmd claude; then
  log_ok "Claude Code already installed ($(claude --version 2>/dev/null || echo present))."
else
  log_info "Installing Claude Code native CLI..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    log_ok "Claude Code installed."
  else
    log_warn "Claude Code install failed."
  fi
fi

# --- Antigravity CLI (agy) ---------------------------------------------------
# Google's terminal agent, and the one Gemini CLI we keep. It has no unattended
# installer we can pin, but it self-updates, so bring an existing install
# up to date and otherwise point at the docs rather than guessing a URL.
if has_cmd agy; then
  log_info "Updating Antigravity CLI ($(agy --version 2>/dev/null || echo unknown))..."
  agy update && log_ok "Antigravity CLI up to date." \
    || log_warn "\`agy update\` reported errors."
else
  log_warn "Antigravity CLI (agy) not found — install it from"
  log_warn "  https://antigravity.google/docs/cli/reference"
  log_warn "then re-run this module to keep it updated."
fi

# --- Claude Code config ------------------------------------------------------
# Symlink the versioned Claude Code settings into ~/.claude so this repo stays
# the single source of truth (edits via /config flow straight back to the repo).
# Only portable, non-sensitive files are tracked: global settings.json and
# CLAUDE.md. Machine-local settings.local.json (permission allowlists) is
# intentionally NOT managed here.
log_step "Linking Claude Code config"
claude_src="$DOTFILES_DIR/config/claude"
claude_dst="$HOME/.claude"
mkdir -p "$claude_dst"
for name in settings.json CLAUDE.md; do
  src="$claude_src/$name"
  dst="$claude_dst/$name"
  [[ -f "$src" ]] || { log_warn "Missing $src; skipping."; continue; }
  # Back up a real (non-symlink) file once, then symlink to the repo.
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    cp -n "$dst" "${dst}.bak-$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
  fi
  ln -sfn "$src" "$dst"
  log_ok "$name -> $src"
done
