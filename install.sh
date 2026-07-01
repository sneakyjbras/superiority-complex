#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Superiority Complex — one-command Manjaro/Arch bootstrap.
#
# Usage:
#   ./install.sh              Run every module in order (fresh-machine setup).
#   ./install.sh neovim       Run only the module(s) whose name matches "neovim".
#   ./install.sh 20 40        Run modules matching "20" and "40".
#   ./install.sh --list       List available modules and exit.
#
# Design:
#   • Resilient: a failing module is logged and the run continues; a summary is
#     printed at the end and the exit code reflects any failure.
#   • Idempotent: safe to re-run at any time.
#   • Modular: each modules/*.sh is self-contained and can be run on its own.
# -----------------------------------------------------------------------------
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# shellcheck source=lib/common.sh
source "$DOTFILES_DIR/lib/common.sh"
# shellcheck source=config/packages.sh
source "$DOTFILES_DIR/config/packages.sh"

MODULES_DIR="$DOTFILES_DIR/modules"

list_modules() {
  find "$MODULES_DIR" -maxdepth 1 -name '*.sh' -type f | sort
}

# Preconditions: this repo targets Arch-based distros.
need_cmd pacman
need_cmd sudo

# --- Select which modules to run --------------------------------------------
mapfile -t all_modules < <(list_modules)

if [[ "${1:-}" == "--list" ]]; then
  log_step "Available modules"
  for m in "${all_modules[@]}"; do log_info "$(basename "$m")"; done
  exit 0
fi

selected=()
if [[ $# -eq 0 ]]; then
  selected=("${all_modules[@]}")
else
  for pattern in "$@"; do
    matched=0
    for m in "${all_modules[@]}"; do
      if [[ "$(basename "$m")" == *"$pattern"* ]]; then
        selected+=("$m"); matched=1
      fi
    done
    if [[ $matched -eq 0 ]]; then
      log_warn "No module matches '$pattern' (use --list to see options)"
    fi
  done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  log_err "Nothing to run."
  exit 1
fi

# --- Run ---------------------------------------------------------------------
log_step "Bootstrapping from $DOTFILES_DIR"
for m in "${selected[@]}"; do
  run_module "$m"
done

print_summary
summary_status=$?

if [[ $summary_status -eq 0 ]]; then
  log_step "Setup complete."
else
  log_step "Setup finished with errors — see summary above."
fi
exit $summary_status
