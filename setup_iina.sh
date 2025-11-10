#!/bin/bash

# setup iina configs 
if [ ! -d "$HOME/Library/Application\ Support/com.colliderli.iina" ]; then
  echo "IINA directory doesn't exist, installing iina"
  brew install --cask iina
fi

rsync -av iina/ ~/Library/Application\ Support/com.colliderli.iina/input_conf
