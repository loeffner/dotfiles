# Setup fzf
# ---------
fzf_bin="$HOME/proj/fzf/bin"

if [[ ":$PATH:" != *":$fzf_bin:"* ]]; then
  PATH="$fzf_bin:$PATH"
fi

# Load fzf shell integration
source <(fzf --bash)

fe() {
  IFS=$'\n' files=($(fzf --tmux \
    --query="$1" \
    --multi \
    --select-1 \
    --exit-0 \
    --preview='bat --color=always {}' \
    --preview-window='right,60%,<80(hidden)'
  ))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

fo() {
  IFS=$'\n' out=("$(fzf --tmux \
    --query="$1" \
    --exit-0 \
    --expect=ctrl-o,ctrl-e \
    --preview='bat --color=always {}' \
    --preview-window='right,60%,<80(hidden)'
  )")

  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)

  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}
