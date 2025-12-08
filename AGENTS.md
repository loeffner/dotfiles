# Agent Instructions

This repository contains dotfiles for a Linux bash environment. The files are designed to be symlinked to the home directory. The repo can be cloned anywhere (e.g., `~/dotfiles`).

## Repository Structure

**Base files (GitHub - public):**
| File | Purpose |
|------|---------|
| `.bashrc` | Main bash configuration, sources other files, sets up ssh-agent, fzf, zoxide, detects `DOTFILES_DIR` |
| `.bash_aliases` | Aliases and functions for ls, grep, ssh-agent, Python environments |
| `.bash_profile` | Symlinks to `.bashrc` |
| `.bash_logout` | Logout cleanup |
| `.inputrc` | Readline configuration (completion, history search) |
| `.tmux.conf` | Tmux configuration with catppuccin theme |
| `.fzf.bash` | Fuzzy finder setup |
| `.gitconfig` | Git configuration with aliases, includes `.gitconfig.work` if present |
| `git-completion.bash` | Git tab completion |
| `install.sh` | Installation/uninstallation script |
| `AGENTS.md` | This file - instructions for AI agents |

**Work files (`work/` submodule - Stash, private):**
| File | Purpose |
|------|---------|
| `.work_bashrc` | Work environment setup, sources work aliases, sets PS1 |
| `.bash_work_aliases` | Work-specific aliases and functions |
| `.bash_display` | X11 display management for X2Go sessions |
| `.gitconfig.work` | Work git identity, GPG signing, LFS config |
| `ssh_config` | SSH host configurations (copied, not symlinked) |

## Installation

Run the install script to create symlinks from this repo to `$HOME`:

```bash
./install.sh              # Interactive mode - prompts before overwriting
./install.sh --force      # Overwrite without prompting
./install.sh --no-backup  # Don't create backups
./install.sh --uninstall  # Remove symlinks and restore last backup
```

The script:
- Creates symlinks for base dotfiles
- If `work/` submodule is present, also installs work files
- Copies `ssh_config` (for security - not symlinked)
- Backs up existing files to `~/.dotfiles_backup/<timestamp>/`
- Skips files that are already correctly linked

### Setting up the work submodule

```bash
git submodule update --init    # Initialize work submodule
./install.sh                   # Re-run to install work files
```

## Key Patterns

### Section Headers
All bash files use this comment style for sections:
```bash
###############################################################################
# Section Name
###############################################################################
```

### Bash Aliases
- Navigation: `q` (exit), `c` (clear), `ll`, `la`, `l`
- File editing: `brc`, `bls`, `bdx`, `gconf` open config files in VS Code
- Search: `search`, `search1`, `search2`, `search5` (with depth limits)
- Rsync: `rsync_update`, `rsync_copy`

### Git Aliases (in `.gitconfig`)
- Log: `lg` (last 10 commits, graph), `lga` (all branches)
- Commit: `fix` (fixup commit)
- Push: `force` (push --force-with-lease)
- Rebase: `reb` (interactive rebase with autosquash)
- Reset: `uncommit` (soft reset HEAD~1)
- Cleanup: `clean-merged` (delete merged branches)

### Key Functions
- `search` - Find files containing a pattern (wrapper around find + grep)
- `gitch` - Show files changed compared to a branch (bash function for tab completion)
- `citch` - Open changed files in VS Code
- `vact` - Activate Python virtual environment
- `start_agent`, `stop_agent`, `check_agent` - SSH agent management
- `waitfor` - Wait for a host to become available
- `dx2go` - Set DISPLAY for X2Go sessions (work)

### Environment Variables
- `$DOTFILES_DIR` - Path to this repo (detected from `.bashrc` symlink)
- `$SSH_ENV` - Path to ssh-agent environment file
- `$CONFIG_HOME` - Points to `~/.config`

## Conventions

1. **VS Code**: The `code` alias points to `code-insiders`
2. **Git workflow**: Uses `origin/master` as the default comparison branch
3. **Git config**: Base `.gitconfig` includes `~/.gitconfig.work` if present (for work identity/signing)
4. **SSH keys**: Stored in `~/.ssh/` with host-specific identity files
5. **Symlinks**: Most files are symlinked; `ssh_config` is copied for security

## When Making Changes

- Follow the existing section header style
- Add new aliases in the appropriate section of `.bash_aliases`
- Test functions with tab completion where applicable
- Keep work-specific content in `.bash_work_aliases` (not tracked)

## Work vs Private Content

**Base files are always loaded first**, then work files extend them (if present).

Content that belongs in **work submodule** (`work/`):
- HALCON-related configuration and aliases
- Network shares and mount points
- Specific host configurations (buteo, havik, labor machines, etc.)
- Company-specific tools and paths
- Internal URLs and services
- SSH config with work hosts

Content that belongs in **base/tracked files**:
- General-purpose aliases and functions
- Tool configurations (git, fzf, zoxide, tmux)
- SSH agent management (generic)
- Editor shortcuts
- Shell options and prompt configuration

## Known Issues / TODOs

None currently.
