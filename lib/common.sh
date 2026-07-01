#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Shared helpers for the dotfiles installer: logging, idempotent config edits,
# and a resilient module runner that records a pass/fail summary.
#
# Sourced by install.sh and by every module (so modules can also run stand-alone).
# -----------------------------------------------------------------------------

# --- Paths -------------------------------------------------------------------
# DOTFILES_DIR is exported by install.sh; fall back to this file's grandparent
# so a module can be sourced/run directly.
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# --- Logging -----------------------------------------------------------------
if [[ -t 1 ]]; then
  _C_RESET=$'\033[0m'; _C_BLUE=$'\033[1;34m'; _C_GREEN=$'\033[1;32m'
  _C_YELLOW=$'\033[1;33m'; _C_RED=$'\033[1;31m'; _C_DIM=$'\033[2m'
else
  _C_RESET=""; _C_BLUE=""; _C_GREEN=""; _C_YELLOW=""; _C_RED=""; _C_DIM=""
fi

log_step() { printf '\n%s==>%s %s\n' "$_C_BLUE"   "$_C_RESET" "$*"; }
log_info() { printf '%s  •%s %s\n'   "$_C_DIM"    "$_C_RESET" "$*"; }
log_ok()   { printf '%s  ✔%s %s\n'   "$_C_GREEN"  "$_C_RESET" "$*"; }
log_warn() { printf '%s  !%s %s\n'   "$_C_YELLOW" "$_C_RESET" "$*" >&2; }
log_err()  { printf '%s  x%s %s\n'    "$_C_RED"    "$_C_RESET" "$*" >&2; }

# --- Command helpers ---------------------------------------------------------
has_cmd() { command -v "$1" &>/dev/null; }

need_cmd() {
  if ! has_cmd "$1"; then
    log_err "Required command '$1' not found. Aborting."
    exit 1
  fi
}

# --- Idempotent file edits ---------------------------------------------------
# Append a line to a file only if that exact line is not already present.
append_if_missing() {
  local line="$1" file="$2"
  touch "$file"
  grep -qxF "$line" "$file" || printf '%s\n' "$line" >> "$file"
}

# Append a config line to the user's ~/.zshrc (with a friendly description).
add_to_config() {
  local content="$1" desc="$2" file="${3:-$HOME/.zshrc}"
  if append_if_missing "$content" "$file"; then
    log_info "$desc → $file"
  fi
}

# Ensure a PATH export line is present in both zsh and bash rc files.
add_path_to_shells() {
  local path_line="$1" rc
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    append_if_missing "$path_line" "$rc"
  done
}

# --- Module runner + summary -------------------------------------------------
declare -ga _SUMMARY_NAMES=()
declare -ga _SUMMARY_STATES=()

# run_module <path-to-module.sh>
# Runs a module in a subshell so a failure (or `exit`) cannot abort the whole
# install. Records OK/FAILED for the end-of-run summary.
run_module() {
  local module="$1" name
  name="$(basename "$module")"
  log_step "Running module: $name"
  if bash "$module"; then
    _SUMMARY_NAMES+=("$name"); _SUMMARY_STATES+=("OK")
    log_ok "$name completed"
  else
    _SUMMARY_NAMES+=("$name"); _SUMMARY_STATES+=("FAILED")
    log_warn "$name reported errors (continuing)"
  fi
}

# print_summary  → prints the recorded results; returns 1 if anything failed.
print_summary() {
  local i failed=0
  log_step "Summary"
  for i in "${!_SUMMARY_NAMES[@]}"; do
    if [[ "${_SUMMARY_STATES[$i]}" == "OK" ]]; then
      log_ok "${_SUMMARY_NAMES[$i]}"
    else
      log_err "${_SUMMARY_NAMES[$i]}"
      failed=1
    fi
  done
  return "$failed"
}
