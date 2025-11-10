#!/bin/bash

rsync -av --exclude ".git"  ~/.config/ghostty .
rsync -av --exclude ".git"  ~/.config/nvim .
rsync -av --exclude ".git"  ~/.config/tmux .
rsync -av --exclude ".git"  ~/Library/Application\ Support/com.colliderli.iina/input_conf/ ./iina/
