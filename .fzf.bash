# Setup fzf
# ---------
if [[ ! "$PATH" == */home/loesela/proj/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/proj/fzf/bin"
fi

eval "$(fzf --bash)"
