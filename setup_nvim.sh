#!/bin/bash
# setup nvim
rsync -av nvim ~/.config

# setup latex packages for vimtex
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "debian" ] || [ "$ID" = "ubuntu" ]; then
        echo "Installing LaTeX packages via apt..."
        sudo apt update
        sudo apt install -y texlive-latex-base \
                           texlive-fonts-recommended \
                           texlive-latex-recommended \
                           texlive-latex-extra \
                           latexmk
    else
        echo "Not Debian/Ubuntu, attempting tlmgr..."
        sudo tlmgr update --self
        sudo tlmgr install collection-latex collection-fontsrecommended collection-latexrecommended collection-latexextra latexmk
    fi
fi
