# Setup fd
# --------
if [[ ! "$PATH" == *fd-v10.3.0-x86_64-unknown-linux-musl ]]; then
  PATH="${PATH:+${PATH}:}$HOME/proj/fd/fd-v10.3.0-x86_64-unknown-linux-musl" 
fi
