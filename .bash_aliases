#!/bin/bash

###############################################################################
# ls, grep, rsync and find
###############################################################################

# some more ls aliases
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'

# Enable color support of ls and also add handy aliases.
if [ -x /usr/bin/dircolors ]; then
  test -r "$HOME"/.dircolors && eval "$(dircolors -b "$HOME"/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  # alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

search() {
  local search_path="."
  local grep_pattern=""
  local find_pattern="*"
  local maxdepth=""
  local silent=false

  # Parse command line arguments
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
    -d | --maxdepth)
      if [ -n "$2" ] && [[ "$2" != -* ]]; then
        maxdepth="-maxdepth $2"
        shift
      else
        echo "Error: Missing or invalid value for -d | --maxdepth option." >&2
        return 1
      fi
      ;;
    -s | --silent)
      silent=true
      ;;
    *)
      break
      ;;
    esac
    shift
  done

  # Handle positional parameters after options
  if [[ $# -eq 3 ]]; then
    search_path="$1"
    find_pattern="$2"
    grep_pattern="$3"
  elif [[ $# -eq 2 ]]; then
    search_path="$1"
    grep_pattern="$2"
  elif [[ $# -eq 1 ]]; then
    grep_pattern="$1"
  else
    echo "Usage: search [-d maxdepth] [search_path] [find_pattern] grep_pattern"
    return 1
  fi
  # Print the 'find' command unless in silent mode
  if ! $silent; then
    echo find "$search_path" $maxdepth -type f -name "$find_pattern" -exec grep -l "$grep_pattern" {} +
  fi
  # Run the find command
  find "$search_path" $maxdepth -type f -name "$find_pattern" -exec grep -l "$grep_pattern" {} +
}

alias search1="search -d 1"
alias search2="search -d 2"
alias search5="search -d 5"

alias rsync_update='rsync -a --info=progress2 --delete'
alias rsync_copy='rsync -a --info=progress2'

alias untargz="tar -xvzf"
alias untarxz="tar -xvf"

###############################################################################
# pathways and shortcuts
###############################################################################

# Frequently used command shortcuts
alias q="exit"
alias c="clear"

# Source $HOME/.bashrc
export CONFIG_HOME="$HOME/.config"
alias bashrc="source $HOME/.bashrc"
alias inputrc="bind -f $HOME/.inputrc"

# Install dotfiles (wrapper for install.sh script)
alias install_loesela_bash="$HOME/loesela_bash/install.sh"

# Open often used files in vscode
alias brc="code $HOME/.bashrc"
alias wrc="code $HOME/.bashrc"
alias vimbrc="vim $HOME/.bashrc"
alias vimwrc="vim $HOME/.bashrc"
alias bls="code $HOME/.bash_aliases"
alias wls="code $HOME/.bash_aliases"
alias bdx="code $HOME/.bash_display"
alias gconf="code $HOME/.gitconfig"
alias vimbls="vim $HOME/.bash_aliases"
alias vimwls="vim $HOME/.bash_aliases"

# Find files and open all matches in VSC
cf() {
  local pattern=$1

  code $(find . -type f -iname $pattern)
}

###############################################################################
# git (shell shortcuts - most aliases are in .gitconfig)
###############################################################################

# Shell shortcuts for common git commands (even shorter than git aliases)
alias s="git s"
alias lg="git lg"
alias fetch="git fetch"
alias pull="git pull"
alias push="git push"
alias add="git add -u"
alias commit="git commit -m"
alias switch="git switch"
alias checkout="git checkout"

# Branch management
alias gitls="git br"
alias gitlsr="git brr | sed 's/origin\\///'"
alias delbranch="git branch -D"
alias delbranchclean="git branch | grep -v 'master$' | xargs -I {} git branch -d {}"
alias delbranchcleanf="git branch | grep -v 'master$' | xargs -I {} git branch -D {}"
alias delbranchremote="git push origin --delete"

# These need shell features (functions with args, piping to code)
alias rebase="git rb"

force() {
  git pf
}

fix() {
  git fix "$1"
}

uncommit() {
  git uncommit "$@"
}

# Print files changed vs master (with completion)
gitch() {
  local branch_to_compare=${1:-origin/master}
  git diff --name-only "$branch_to_compare"...HEAD
}

_gitch_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local branches=$(git br)
  mapfile -t COMPREPLY < <(compgen -W "$branches" -- "$cur")
}

complete -F _gitch_completions gitch

# Open changed files in VS Code
alias citch="code \$(gitch)"


# Print information about the current environment.
get() {
    if [ -z "$1" ]; then
        echo "Usage: get <pattern>"
        return 1
    fi
    env | grep --color=auto "$1"
}


###############################################################################
# Python Environments
###############################################################################

# Activate an environment
vact() {
  local dir
  if [[ -z $1 ]]; then
    dir='.'
  else
    dir="$1"
  fi

  source $dir/bin/activate
}


###############################################################################
# ssh (agent)
###############################################################################

SSH_ENV="$HOME/.env/agent-environment-$HOSTNAME"

# Start an ssh-agent and record the environment to a file
start_agent() {
  echo "Starting agent"
  /usr/bin/ssh-agent -t 8h >"${SSH_ENV}"
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" >/dev/null
}

# Stop an ssh-agent, using the environment from start_agent
stop_agent() {
  if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" >/dev/null
    ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent >/dev/null || {
      return 1
    }
    kill $SSH_AGENT_PID
    return 0
  fi
}

# Check an ssh-agent, using the environment from start_agent
check_agent() {
  if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" >/dev/null
    ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent >/dev/null || {
      echo "Agent is not running, SSH_ENV is outdated."
    }
    echo "Agent with PID ${SSH_AGENT_PID} is running."
    echo
    ssh-add -l
    return 0
  fi
}

# Waitfor a host to be responsive
waitfor() {
  local host=$1
  local first_check=true

  while ! ping -c 1 -W 1 "$host" >/dev/null 2>&1; do
    if $first_check; then
      echo -n "Waiting for workstation ($host)"
      first_check=false
    fi
    echo -n "."
    sleep 2
  done

  echo -e "\nWorkstation ($host) is available!"
}

_waitfor_completions() {
  local cur_word=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(compgen -W "$(awk '{print $1}' ~/.ssh/known_hosts | cut -d',' -f1 | sort -u)" -- "$cur_word"))
}

complete -F _waitfor_completions waitfor
