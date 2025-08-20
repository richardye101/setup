#!/bin/bash

sh pull_local.sh
git add .
git commit -m "updated nvim or tmux configs"
git push
