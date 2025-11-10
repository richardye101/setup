#!/bin/bash

# In case we don't have it installed
brew update && brew install luarocks

sh setup_ghostty.sh
sh setup_nvim.sh
sh setup_tmux.sh
sh setup_iina.sh
