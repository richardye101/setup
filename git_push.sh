#!/bin/bash

sh pull_local.sh
git add .
if [ -n "$1" ]; then
  git commit -m "$1"
else
  git commit -m "updated nvim or tmux configs"
fi
git push
