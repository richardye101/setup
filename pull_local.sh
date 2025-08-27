#!/bin/bash

rsync -av --exclude ".git"  ~/.config/nvim .
rsync -av --exclude ".git"  ~/.config/tmux .
