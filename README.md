# Dotfiles

Personal bash dotfiles for Linux. Symlinked to `$HOME`.

## Quick Setup

```bash
git clone git@github.com:loeffner/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### With work files (MVTec only)

```bash
git submodule update --init
./install.sh
```

## What's Included

- Shell config (`.bashrc`, `.bash_aliases`)
- Git completion and aliases
- fzf, zoxide, tmux setup
- SSH agent management

## Files

| File | Purpose |
|------|---------|
| `.bashrc` | Main config, sources other files |
| `.bash_aliases` | Aliases and functions |
| `.inputrc` | Readline config |
| `.tmux.conf` | Tmux with catppuccin |
| `.fzf.bash` | Fuzzy finder |
