#!/bin/bash

rsync -av --exclude ".git"  ~/.config/ghostty .
rsync -av --exclude ".git"  ~/.config/nvim .
rsync -av --exclude ".git"  ~/.config/tmux .
rsync -av --exclude ".git"  ~/Library/Application\ Support/com.colliderli.iina/input_conf/ ./iina/
rsync -av ~/.zshrc .
rsync -av ~/Library/Application\ Support/Firefox/Profiles/*.default-release*/chrome/ ./Firefox/chrome/

# rex
rsync -av ~/.config/rex/init.lua ./rex/
rsync -av ~/.local/bin/rex-composer ~/.local/bin/ompa ./rex/bin/

# omp
rsync -av ~/.omp/agent/config.yml ~/.omp/agent/models.yml ~/.omp/agent/RULES.md ./omp/agent/
rsync -av ~/.omp/agent/themes/titanium-prompts.json ./omp/agent/themes/
rsync -av ~/.omp/agent/extensions/compact-tool-cards.ts ./omp/agent/extensions/
rsync -av --exclude node_modules ~/.omp/agent/extensions/ci-watch ./omp/agent/extensions/
