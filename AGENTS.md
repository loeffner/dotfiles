# Agent Instructions

This repository contains dotfiles for a Linux bash environment. The files are designed to be symlinked from `~/loesela_bash/` to the home directory.

## Repository Structure

**Base files (GitHub - public):**
| File | Purpose |
|------|---------|
| `.bashrc` | Main bash configuration, sources other files, sets up ssh-agent, fzf, zoxide |
| `.bash_aliases` | Aliases and functions for ls, grep, git, ssh-agent, Python environments |
| `.bash_profile` | Symlinks to `.bashrc` |
| `.bash_logout` | Logout cleanup |
| `.inputrc` | Readline configuration (completion, history search) |
| `.tmux.conf` | Tmux configuration with catppuccin theme |
| `.fzf.bash` | Fuzzy finder setup |
| `git-completion.bash` | Git tab completion |
| `install.sh` | Installation script |

**Work files (`work/` submodule - Stash, private):**
| File | Purpose |
|------|---------|
| `.work_bashrc` | Work environment setup, sources work aliases, sets PS1 |
| `.bash_work_aliases` | Work-specific aliases and functions |
| `.bash_display` | X11 display management for X2Go sessions |
| `ssh_config` | SSH host configurations (copied, not symlinked) |

## Installation

Run the install script to create symlinks from this repo to `$HOME`:

```bash
./install.sh          # Interactive mode - prompts before overwriting
./install.sh --force  # Overwrite without prompting
./install.sh --no-backup  # Don't create backups
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

The `install_loesela_bash` alias in `.bash_aliases` calls this script.

## Key Patterns

### Section Headers
All bash files use this comment style for sections:
```bash
###############################################################################
# Section Name
###############################################################################
```

### Aliases
- Git shortcuts: `s`, `status`, `diff`, `lg`, `fetch`, `pull`, `add`, `commit`, `push`, `switch`, `checkout`
- Navigation: `q` (exit), `c` (clear), `ll`, `la`, `l`
- File editing: `brc`, `bls`, `bdx`, `gconf` open config files in VS Code

### Key Functions
- `search` - Find files containing a pattern (wrapper around find + grep)
- `gitch` - Show files changed compared to a branch
- `vact` - Activate Python virtual environment
- `start_agent`, `stop_agent`, `check_agent` - SSH agent management
- `waitfor` - Wait for a host to become available
- `dx2go` - Set DISPLAY for X2Go sessions

### Environment Variables
- `$SSH_ENV` - Path to ssh-agent environment file
- `$CONFIG_HOME` - Points to `~/.config`

## Conventions

1. **VS Code**: The `code` alias points to `code-insiders`
2. **Git workflow**: Uses `origin/master` as the default comparison branch
3. **SSH keys**: Stored in `~/.ssh/` with host-specific identity files
4. **Symlinks**: Most files are symlinked; `ssh_config` is copied for security

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
