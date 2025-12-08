#!/bin/bash

# In case we don't have brew 
if which brew >/dev/null; then
    echo "Homebrew is installed"
else
    echo "Homebrew is not found in the PATH, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update && brew upgrade

# to compare the remote one to the current brew bundle, and check if there are any non-comment lines
if comm -23 <(sort .Brewfile) <(brew bundle dump --force --describe --file=/dev/stdout | sort) | grep -vq '^#'; then
    echo "Found a missing package, running entire brew bundle"
    brew bundle install --file=.Brewfile
else
    echo "No homebrew packages missing!"
fi
