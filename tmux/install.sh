#!/bin/bash
#
# tmux/install.sh - Install tmux plugin manager (tpm)
#
# Clones tpm to ~/.tmux/plugins/tpm and installs plugins.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

TPM_DIR="$HOME/.tmux/plugins/tpm"
TPM_REPO="https://github.com/tmux-plugins/tpm.git"

if [[ -d "$TPM_DIR" ]]; then
  log_success "tpm already installed at $TPM_DIR"
else
  log_info "Installing tpm..."
  git clone "$TPM_REPO" "$TPM_DIR"
  log_success "tpm installed to $TPM_DIR"
fi

log_info "To install plugins, start tmux and press: prefix + I"
log_info "(Default prefix is Ctrl+Space after sourcing this config)"
