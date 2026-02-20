#!/bin/bash
#
# lib/helpers.sh - Shared helper functions for dotfiles scripts
#
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/helpers.sh"
#

###############################################################################
# Logging
###############################################################################

log_info() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

log_success() {
  echo -e "\033[1;32m[OK]\033[0m $1"
}

log_warning() {
  echo -e "\033[1;33m[WARN]\033[0m $1"
}

log_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

###############################################################################
# Path utilities
###############################################################################

# Add a directory to PATH if not already present
add_path_entry() {
  local var=PATH entry=$1

  [ -n "$var" ]   || { echo "Error: no variable name specified"; return 1; }
  [ -n "$entry" ] || { echo "Error: no entry specified"; return 1; }

  # Canonicalize path and strip trailing slash
  entry=$(readlink -f -- "$entry") || return 1
  entry=${entry%/}

  # Indirect expansion of the variable
  local current=${!var}

  # Check for exact match in colon-separated list
  case ":$current:" in
    *":$entry:"*) return 0 ;;  # already present
  esac

  # Prepend entry
  if [ -n "$current" ]; then
    export "$var=$entry:$current"
  else
    export "$var=$entry"
  fi
}
