#!/bin/bash

# setup tmux
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "TPM directory doesn't exist, pulling"
  git clone https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm
fi

rsync -av tmux ~/.config
tmux source ~/.config/tmux/tmux.conf
# install plugins with <prefix>+I (probably ctrl+space then shift+I)
