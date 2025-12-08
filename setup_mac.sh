#!/bin/bash
cp .zshrc ~/

source terminal-config/powerlevel10k/powerlevel10k.zsh-theme
source terminal-config/zsh-autosuggestions/zsh-autosuggestions.zsh
source terminal-config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
sh setup_homebrew.sh
sh setup_ghostty.sh
sh setup_nvim.sh
sh setup_tmux.sh
sh setup_iina.sh
