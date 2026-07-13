#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Neovim setup (lazy.nvim + Lua config):
#   • Install neovim and its tooling deps (incl. a C toolchain for treesitter
#     parsers and the avante.nvim `make` build).
#   • Ensure Node.js + npm (Copilot / claudecode.nvim).
#   • Symlink config/nvim/init.lua -> ~/.config/nvim/init.lua (single source of truth).
#   • Symlink vim/vi -> nvim.
#   • Sync plugins headlessly (lazy.nvim self-bootstraps from init.lua).
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/config/packages.sh"

# --- 1) Remove classic Vim (no dual boot) ------------------------------------
for pkg in vim gvim; do
  if pacman -Qq "$pkg" &>/dev/null; then
    log_info "Removing $pkg (using Neovim instead)"
    sudo pacman -Rns --noconfirm "$pkg" || true
  fi
done

# --- 2) Base packages --------------------------------------------------------
log_step "Installing Neovim and dependencies"
# shellcheck disable=SC2086
sudo pacman -S --needed --noconfirm "${NVIM_PKGS[@]}" \
  || log_warn "Some Neovim packages failed to install."

# Ensure Node.js + npm (avoid Manjaro nodejs vs nodejs-lts conflicts).
if pacman -Qq nodejs-lts-iron &>/dev/null || pacman -Qq nodejs &>/dev/null; then
  sudo pacman -S --needed --noconfirm npm || log_warn "npm install failed."
else
  sudo pacman -S --needed --noconfirm nodejs-lts-iron npm \
    || sudo pacman -S --needed --noconfirm nodejs npm \
    || log_warn "Node.js/npm install failed."
fi

# --- 3) Symlink the config ---------------------------------------------------
# (lazy.nvim self-bootstraps from init.lua on first launch — no vim-plug.)
log_step "Linking Neovim config"
mkdir -p "$HOME/.config/nvim"
src="$DOTFILES_DIR/config/nvim/init.lua"
dst="$HOME/.config/nvim/init.lua"

# Remove any legacy init.vim (no dual boot).
rm -f "$HOME/.config/nvim/init.vim"

# Back up a real (non-symlink) config once, then symlink to the repo.
if [[ -e "$dst" && ! -L "$dst" ]]; then
  cp -n "$dst" "${dst}.bak-$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
fi
ln -sfn "$src" "$dst"
log_ok "init.lua -> $src"

# --- 4) vim/vi -> nvim -------------------------------------------------------
mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vim"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vi"
add_path_to_shells 'export PATH="$HOME/.local/bin:$PATH"'

# --- 5) Sync plugins headlessly ----------------------------------------------
# lazy.nvim clones itself from init.lua, then installs/builds every plugin
# (incl. the avante.nvim `make` step and treesitter parsers).
if has_cmd nvim; then
  log_step "Syncing Neovim plugins (headless, lazy.nvim)"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null \
    || log_warn "lazy.nvim sync reported issues."
  log_ok "Plugins synced"
else
  log_warn "nvim not found; skipping plugin sync."
fi
