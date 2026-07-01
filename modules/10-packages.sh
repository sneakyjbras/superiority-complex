#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# System packages: full upgrade, official-repo groups, AUR helper bootstrap,
# and AUR applications. Package lists live in config/packages.sh.
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/config/packages.sh"

# --- 1) System upgrade -------------------------------------------------------
log_step "Updating system (pacman -Syu)"
sudo pacman -Syu --noconfirm || log_warn "System upgrade reported issues; continuing."

# --- 2) Official-repo groups -------------------------------------------------
# Install 'core' first so git + base-devel are present for the yay bootstrap.
install_group() {
  local grp="$1"
  log_info "[pacman] ${grp}: ${PACMAN_GROUPS[$grp]}"
  # shellcheck disable=SC2086
  sudo pacman -S --needed --noconfirm ${PACMAN_GROUPS[$grp]} \
    || log_warn "Some packages in group '${grp}' failed to install."
}

log_step "Installing official-repo packages"
if [[ -n "${PACMAN_GROUPS[core]:-}" ]]; then
  install_group core
fi
for grp in "${!PACMAN_GROUPS[@]}"; do
  [[ "$grp" == "core" ]] && continue
  install_group "$grp"
done

# --- 3) AUR helper -----------------------------------------------------------
detect_aur_helper() {
  local helper
  for helper in yay paru; do
    if has_cmd "$helper"; then echo "$helper"; return 0; fi
  done
  return 1
}

bootstrap_yay() {
  log_step "No AUR helper found — bootstrapping yay"
  if ! has_cmd git || ! has_cmd makepkg; then
    log_warn "git/base-devel missing; cannot bootstrap yay. Skipping AUR."
    return 1
  fi
  local tmp
  tmp="$(mktemp -d)"
  if git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay" \
    && ( cd "$tmp/yay" && makepkg -si --noconfirm ); then
    rm -rf "$tmp"
    log_ok "yay installed"
    return 0
  fi
  rm -rf "$tmp"
  log_warn "yay bootstrap failed; skipping AUR packages."
  return 1
}

aur_helper="$(detect_aur_helper || true)"
if [[ -z "$aur_helper" ]]; then
  if bootstrap_yay; then aur_helper="yay"; fi
fi

# --- 4) AUR packages ---------------------------------------------------------
if [[ -n "$aur_helper" && ${#AUR_PKGS[@]} -gt 0 ]]; then
  log_step "Installing AUR packages via $aur_helper"
  log_info "${AUR_PKGS[*]}"
  "$aur_helper" -S --needed --noconfirm "${AUR_PKGS[@]}" \
    || log_warn "Some AUR packages failed to install."
else
  log_warn "No AUR helper available; skipping AUR packages: ${AUR_PKGS[*]:-none}"
fi
