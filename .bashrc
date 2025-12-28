# $HOME/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

###############################################################################
# Check if interactive
###############################################################################

case $- in
*i*) ;;
*) return ;;
esac

###############################################################################
# Options for bash(1)
###############################################################################

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# expand directory variables to its full path using tab completion
# appending the variable with a forward slash is required before pressing tab.
shopt -s direxpand

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
command -v lesspipe &>/dev/null && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  # NixOS: check multiple locations
  for f in /run/current-system/sw/share/bash-completion/bash_completion \
           /usr/share/bash-completion/bash_completion \
           /etc/bash_completion; do
    [ -f "$f" ] && . "$f" && break
  done
fi

###############################################################################
# Colors
###############################################################################

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*) ;;
esac

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


###############################################################################
# DOTFILES_DIR and bash prompt (may be overwritten by included files
###############################################################################

# Detect dotfiles directory (where this .bashrc is symlinked from)
if [ -L "$HOME/.bashrc" ]; then
  DOTFILES_DIR="$(dirname "$(readlink -f "$HOME/.bashrc")")"
  export DOTFILES_DIR
fi

# Include git-prompt file
if [ -f "$DOTFILES_DIR/git/git-prompt.sh" ]; then
  . "$DOTFILES_DIR"/git/git-prompt.sh
fi

PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s)")'; PS1='\[\e[32m\]♞\[\e[0m\] \[\e[94m\]\w\[\e[93m\]${PS1_CMD1}\n\[\e[32m\] ↳\[\e[0m\] \[\e[32m\]\$\[\e[0m\] '

###############################################################################
# Private and work bash tools
###############################################################################

# Personal Aliases (loaded first - defines SSH_ENV, start_agent, etc.)
if [ -f $HOME/.bash_aliases ]; then
  . $HOME/.bash_aliases
fi

# Work Tools (from work/ submodule - sources .bash_work_aliases internally)
# Gracefully skipped if submodule not present
if [ -f $HOME/.work_bashrc ]; then
  . $HOME/.work_bashrc
fi


###############################################################################
# ssh-agent
###############################################################################

# If ssh environment file exists, write it to the standard device
if [ -f "$SSH_ENV" ]; then
  . "${SSH_ENV}" >/dev/null
  ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent >/dev/null || {
    start_agent
  }
else
  if [ ! -d "${HOME}/.env" ]; then
    mkdir $HOME/.env
  fi
  start_agent
fi

export GPG_TTY=$(tty)
# Launch GPG agent if available (NixOS manages this via programs.gnupg.agent)
command -v gpgconf &>/dev/null && gpgconf --launch gpg-agent 2>/dev/null


###############################################################################
# fuzzy-find
###############################################################################

# fzf integration (if installed)
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# export FZF_DEFAULT_COMMAND='find . --type f --strip-cwd-prefix --hidden --follow --exclude .git'
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


###############################################################################
# code-insiders
###############################################################################

alias code='code-insiders'


###############################################################################
# zoxide
###############################################################################

# Source shared helpers if not already loaded (provides add_path_entry)
if ! command -v add_path_entry &> /dev/null && [[ -n "$DOTFILES_DIR" ]]; then
  source "$DOTFILES_DIR/lib/helpers.sh"
fi

add_path_entry "$HOME"/.local/bin

# zoxide - smarter cd (if installed)
command -v zoxide &>/dev/null && eval "$(zoxide init --cmd cd bash)"
