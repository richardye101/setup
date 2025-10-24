#!/bin/bash

brew update && brew install luarocks
# setup nvim
rsync -av nvim ~/.config

