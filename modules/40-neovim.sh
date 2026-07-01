#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Neovim setup (vim-plug + Lua config):
#   • Install neovim and its tooling deps.
#   • Ensure Node.js + npm (Copilot / claudecode.nvim).
#   • Symlink config/nvim/init.lua -> ~/.config/nvim/init.lua (single source of truth).
#   • Symlink vim/vi -> nvim.
#   • Install plugins headlessly.
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

# --- 3) vim-plug -------------------------------------------------------------
log_step "Installing vim-plug"
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  || log_warn "Failed to download vim-plug."

# --- 4) Symlink the config ---------------------------------------------------
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

# --- 5) vim/vi -> nvim -------------------------------------------------------
mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vim"
ln -sf /usr/bin/nvim "$HOME/.local/bin/vi"
add_path_to_shells 'export PATH="$HOME/.local/bin:$PATH"'

# --- 6) Install plugins headlessly -------------------------------------------
if has_cmd nvim; then
  log_step "Installing Neovim plugins (headless)"
  nvim --headless +PlugInstall +qall 2>/dev/null \
    || log_warn "PlugInstall reported issues."
  log_ok "Plugins installed"
else
  log_warn "nvim not found; skipping plugin install."
fi
