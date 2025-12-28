# Setup fzf
# ---------
fzf_bin="$HOME/proj/fzf/bin"

if [[ ":$PATH:" != *":$fzf_bin:"* ]]; then
  PATH="$fzf_bin:$PATH"
fi

# Load fzf shell integration
source <(fzf --bash)
