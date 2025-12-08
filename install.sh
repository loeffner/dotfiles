#!/bin/bash
#
# install.sh - Install dotfiles
#
# Creates symlinks from this repo to $HOME, backing up existing files.
# Usage: ./install.sh [--force] [--no-backup]
#

set -euo pipefail

###############################################################################
# Configuration
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/work"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Base files to symlink (always installed)
declare -A SYMLINKS=(
  [".bashrc"]="$HOME/.bashrc"
  [".bash_aliases"]="$HOME/.bash_aliases"
  [".bash_profile"]="$HOME/.bash_profile"
  [".bash_logout"]="$HOME/.bash_logout"
  [".inputrc"]="$HOME/.inputrc"
  [".fzf.bash"]="$HOME/.fzf.bash"
  [".tmux.conf"]="$HOME/.tmux.conf"
  [".gitconfig"]="$HOME/.gitconfig"
  ["git-completion.bash"]="$HOME/git-completion.bash"
)

# Work files to symlink (from work/ submodule, skipped if not present)
declare -A WORK_SYMLINKS=(
  [".work_bashrc"]="$HOME/.work_bashrc"
  [".bash_work_aliases"]="$HOME/.bash_work_aliases"
  [".bash_display"]="$HOME/.bash_display"
  [".gitconfig.work"]="$HOME/.gitconfig.work"
)

# Work files to copy (from work/ submodule, skipped if not present)
declare -A WORK_COPIES=(
  ["ssh_config"]="$HOME/.ssh/config"
)

###############################################################################
# Options
###############################################################################

FORCE=false
NO_BACKUP=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force)
      FORCE=true
      shift
      ;;
    --no-backup)
      NO_BACKUP=true
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install dotfiles by creating symlinks to \$HOME.

Options:
  -f, --force     Overwrite existing files without prompting
  --no-backup     Don't create backups of existing files
  -h, --help      Show this help message

Backup location: ~/.dotfiles_backup/<timestamp>/
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

###############################################################################
# Helper Functions
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

backup_file() {
  local file="$1"

  if [[ "$NO_BACKUP" == true ]]; then
    return 0
  fi

  if [[ -e "$file" || -L "$file" ]]; then
    mkdir -p "$BACKUP_DIR"
    local backup_path="$BACKUP_DIR/$(basename "$file")"
    cp -P "$file" "$backup_path"
    log_info "Backed up: $file -> $backup_path"
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"

  # Check if source exists
  if [[ ! -e "$SCRIPT_DIR/$source" ]]; then
    log_error "Source file not found: $SCRIPT_DIR/$source"
    return 1
  fi

  # Handle existing target
  if [[ -e "$target" || -L "$target" ]]; then
    # Check if already correctly linked
    if [[ -L "$target" && "$(readlink "$target")" == "$SCRIPT_DIR/$source" ]]; then
      log_success "Already linked: $target"
      return 0
    fi

    if [[ "$FORCE" != true ]]; then
      local backup_note=""
      if [[ "$NO_BACKUP" != true ]]; then
        backup_note=" (will be backed up)"
      fi
      read -p "File exists: $target. Overwrite?${backup_note} [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Skipped: $target"
        return 0
      fi
    fi

    backup_file "$target"
    rm -f "$target"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$target")"

  # Create symlink
  ln -s "$SCRIPT_DIR/$source" "$target"
  log_success "Linked: $target -> $SCRIPT_DIR/$source"
}

copy_file() {
  local source="$1"
  local target="$2"

  # Check if source exists
  if [[ ! -e "$SCRIPT_DIR/$source" ]]; then
    log_error "Source file not found: $SCRIPT_DIR/$source"
    return 1
  fi

  # Handle existing target
  if [[ -e "$target" ]]; then
    # Check if content is identical
    if diff -q "$SCRIPT_DIR/$source" "$target" &>/dev/null; then
      log_success "Already up to date: $target"
      return 0
    fi

    if [[ "$FORCE" != true ]]; then
      local backup_note=""
      if [[ "$NO_BACKUP" != true ]]; then
        backup_note=" (will be backed up)"
      fi
      read -p "File exists: $target. Overwrite?${backup_note} [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Skipped: $target"
        return 0
      fi
    fi

    backup_file "$target"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$target")"

  # Copy file
  cp "$SCRIPT_DIR/$source" "$target"
  log_success "Copied: $target"
}

###############################################################################
# Main
###############################################################################

echo "Installing dotfiles..."
echo "Source: $SCRIPT_DIR"
echo

# Create base symlinks
for source in "${!SYMLINKS[@]}"; do
  target="${SYMLINKS[$source]}"
  create_symlink "$source" "$target"
done

# Check if work submodule is present
if [[ -d "$WORK_DIR" ]]; then
  echo
  log_info "Work submodule found, installing work files..."

  # Create work symlinks
  for source in "${!WORK_SYMLINKS[@]}"; do
    target="${WORK_SYMLINKS[$source]}"
    create_symlink "work/$source" "$target"
  done

  # Copy work files
  for source in "${!WORK_COPIES[@]}"; do
    target="${WORK_COPIES[$source]}"
    copy_file "work/$source" "$target"
  done
else
  echo
  log_warning "Work submodule not found at $WORK_DIR - skipping work files"
  log_info "To install work files, initialize the submodule: git submodule update --init"
fi

echo
log_success "Installation complete!"

if [[ -d "$BACKUP_DIR" ]]; then
  log_info "Backups saved to: $BACKUP_DIR"
fi

echo
echo "Run 'source ~/.bashrc' or start a new terminal to apply changes."
