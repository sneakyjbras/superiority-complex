#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# i3 window manager — replaces Plasma as the default desktop session.
#   • Install i3 and the pieces Plasma used to provide (launcher, compositor,
#     notifications, tray applets, lock-on-idle, screenshots).
#   • Symlink config/i3/config and config/i3status/config into ~/.config.
#   • Make i3 the session SDDM pre-selects at login.
#
# Plasma is deliberately left INSTALLED. i3 is X11-only, so this also means the
# session moves from Wayland to Xorg. To go back, pick "Plasma" at the SDDM
# session menu — nothing here uninstalls it.
#
# Package list: I3_PKGS in config/packages.sh.
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/config/packages.sh"

# --- 1) Packages -------------------------------------------------------------
log_step "Installing i3 and desktop components"
sudo pacman -S --needed --noconfirm "${I3_PKGS[@]}" \
  || log_warn "Some i3 packages failed to install."

# --- 2) Config ---------------------------------------------------------------
# Symlink both configs to the repo so this stays the single source of truth.
log_step "Linking i3 config"
link_config() {
  local src="$1" dst="$2"
  [[ -f "$src" ]] || { log_warn "Missing $src; skipping."; return 1; }
  mkdir -p "$(dirname "$dst")"
  # Back up a real (non-symlink) config once, then symlink to the repo.
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    cp -n "$dst" "${dst}.bak-$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
  fi
  ln -sfn "$src" "$dst"
  log_ok "$(basename "$(dirname "$dst")")/$(basename "$dst") -> $src"
}

link_config "$DOTFILES_DIR/config/i3/config"       "$HOME/.config/i3/config"
link_config "$DOTFILES_DIR/config/i3status/config" "$HOME/.config/i3status/config"

# --- 3) Make i3 the default session -----------------------------------------
# SDDM runs with RememberLastSession=true, so the session it pre-selects comes
# from the user's AccountsService record rather than from sddm.conf. Write it
# directly so the very first login after this already lands in i3.
log_step "Setting i3 as the default SDDM session"
session_file="/usr/share/xsessions/i3.desktop"
if [[ ! -f "$session_file" ]]; then
  log_warn "$session_file not found — i3 did not install correctly; leaving the"
  log_warn "default session alone so you are not locked out of a desktop."
else
  acct_file="/var/lib/AccountsService/users/$USER"
  sudo mkdir -p /var/lib/AccountsService/users
  if sudo test -f "$acct_file"; then
    sudo cp -n "$acct_file" "${acct_file}.bak-$(date +%Y%m%d%H%M%S)" || true
    # Replace any existing Session/XSession keys, then re-add ours.
    sudo sed -i -E '/^(X?Session)=/d' "$acct_file"
    sudo sed -i -E 's|^\[User\]$|[User]\nXSession=i3\nSession=i3.desktop|' "$acct_file"
  else
    printf '[User]\nXSession=i3\nSession=i3.desktop\n' | sudo tee "$acct_file" >/dev/null
  fi
  sudo chmod 0600 "$acct_file"
  log_ok "i3 is now the default session (Plasma still selectable at login)."
fi

# --- 4) Sanity check ---------------------------------------------------------
# A bad i3 config means a login that drops straight back to SDDM, so validate it
# before the user ever logs out.
if has_cmd i3; then
  log_step "Validating i3 config"
  if i3 -C -c "$HOME/.config/i3/config" >/dev/null 2>&1; then
    log_ok "i3 config is valid."
  else
    log_err "i3 config FAILED validation:"
    i3 -C -c "$HOME/.config/i3/config" 2>&1 | sed 's/^/    /'
    log_warn "Fix this before logging out, or pick Plasma at the login screen."
  fi
fi
