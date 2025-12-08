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
  [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}
