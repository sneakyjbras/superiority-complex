#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Konsole themes: install any shipped .profile / .colorscheme files into the
# user's Konsole data directory.
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_DIR/lib/common.sh"

KONSOLE_SRC="$DOTFILES_DIR/konsole"
KONSOLE_DST="$HOME/.local/share/konsole"

if [[ ! -d "$KONSOLE_SRC" ]]; then
  log_warn "No konsole/ directory in repo; skipping."
  exit 0
fi

mkdir -p "$KONSOLE_DST"

shopt -s nullglob
konsole_files=("$KONSOLE_SRC"/*.profile "$KONSOLE_SRC"/*.colorscheme)
shopt -u nullglob

if (( ${#konsole_files[@]} == 0 )); then
  log_warn "No .profile/.colorscheme files found in $KONSOLE_SRC; skipping."
  exit 0
fi

log_step "Installing Konsole profiles/colorschemes"
for src in "${konsole_files[@]}"; do
  cp -f "$src" "$KONSOLE_DST/$(basename "$src")"
  log_info "$(basename "$src")"
done
log_ok "Konsole themes installed to $KONSOLE_DST"
