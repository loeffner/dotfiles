#!/bin/bash
#
# install.sh - Install/uninstall dotfiles
#
# Creates symlinks from this repo to $HOME, backing up existing files.
# Usage: ./install.sh [--force] [--no-backup] [--uninstall]
#

set -euo pipefail

###############################################################################
# Configuration
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/work"
BACKUP_BASE="$HOME/.dotfiles_backup"
BACKUP_DIR="$BACKUP_BASE/$(date +%Y%m%d_%H%M%S)"

# Source shared helpers
source "$SCRIPT_DIR/lib/helpers.sh"

# Base files to symlink (always installed)
declare -A SYMLINKS=(
  [".bashrc"]="$HOME/.bashrc"
  [".bash_aliases"]="$HOME/.bash_aliases"
  [".bash_profile"]="$HOME/.bash_profile"
  [".bash_logout"]="$HOME/.bash_logout"
  [".inputrc"]="$HOME/.inputrc"
  [".fzf.bash"]="$HOME/.fzf.bash"
  [".fd.bash"]="$HOME/.fd.bash"
  [".bat.bash"]="$HOME/.bat.bash"
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
UNINSTALL=false

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
    -u|--uninstall)
      UNINSTALL=true
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install dotfiles by creating symlinks to \$HOME.

Options:
  -f, --force     Overwrite existing files without prompting
  --no-backup     Don't create backups of existing files
  -u, --uninstall Remove symlinks and restore last backup
  -h, --help      Show this help message

Backup location: ~/.dotfiles_backup/<timestamp>/
EOF
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

###############################################################################
# Helper Functions
###############################################################################

get_latest_backup() {
  if [[ -d "$BACKUP_BASE" ]]; then
    ls -1d "$BACKUP_BASE"/*/ 2>/dev/null | sort -r | head -n1
  fi
}

remove_symlink() {
  local target="$1"

  if [[ -L "$target" ]]; then
    rm -f "$target"
    log_success "Removed symlink: $target"
    return 0
  elif [[ -e "$target" ]]; then
    log_warning "Not a symlink, skipped: $target"
    return 1
  else
    log_info "Does not exist: $target"
    return 0
  fi
}

restore_from_backup() {
  local backup_dir="$1"
  local target="$2"
  local filename
  filename="$(basename "$target")"
  local backup_file="$backup_dir/$filename"

  if [[ -f "$backup_file" ]]; then
    cp -P "$backup_file" "$target"
    log_success "Restored: $backup_file -> $target"
    return 0
  else
    log_info "No backup found for: $filename"
    return 1
  fi
}

do_uninstall() {
  log_info "Uninstalling dotfiles..."

  local latest_backup
  latest_backup="$(get_latest_backup)"

  if [[ -n "$latest_backup" ]]; then
    log_info "Found backup: $latest_backup"
  else
    log_warning "No backup found in $BACKUP_BASE"
  fi
  echo

  # Remove base symlinks
  for target in "${SYMLINKS[@]}"; do
    remove_symlink "$target"
    if [[ -n "$latest_backup" ]]; then
      restore_from_backup "$latest_backup" "$target"
    fi
  done

  # Remove work symlinks
  for target in "${WORK_SYMLINKS[@]}"; do
    remove_symlink "$target"
    if [[ -n "$latest_backup" ]]; then
      restore_from_backup "$latest_backup" "$target"
    fi
  done

  # Note: not restoring copied files (ssh_config) to avoid overwriting user changes

  echo
  log_success "Uninstall complete!"

  if [[ -n "$latest_backup" ]]; then
    log_info "Restored from: $latest_backup"
  fi
}

backup_file() {
  local file="$1"

  if [[ "$NO_BACKUP" == true ]]; then
    return 0
  fi

  if [[ -e "$file" || -L "$file" ]]; then
    mkdir -p "$BACKUP_DIR"
    local backup_path
    backup_path="$BACKUP_DIR/$(basename "$file")"
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

if [[ "$UNINSTALL" == true ]]; then
  do_uninstall
  exit 0
fi

log_info "Installing dotfiles from $SCRIPT_DIR"
echo

# Create base symlinks
for source in "${!SYMLINKS[@]}"; do
  target="${SYMLINKS[$source]}"
  create_symlink "$source" "$target"
done

# Check if work submodule is present
if [[ -n "$(ls -A 'work' )" ]]; then
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
log_info "Run 'source ~/.bashrc' or start a new terminal to apply changes."
