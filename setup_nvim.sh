#!/bin/bash
# setup nvim
rsync -av nvim ~/.config

# setup latex packages for vimtex
sudo tlmgr update --self
sudo tlmgr install collection-latex collection-fontsrecommended collection-latexrecommended collection-latexextra latexmk

