#!/bin/bash

# setup oh-my-zsh and powerlevel10k
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
cp .zshrc ~/
cp .p10k.zsh ~/
exec zsh

./setup_homebrew.sh
./setup_ghostty.sh
./setup_nvim.sh
./setup_tmux.sh
./setup_iina.sh
