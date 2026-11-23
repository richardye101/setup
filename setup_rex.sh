#!/bin/bash
# Installs the Rex config, the composer and the ompa launcher. Install Rex first.
# The composer and ompa call `omp`, so they need omp installed (setup_omp.sh).
cd "$(dirname "$0")" || exit 1

mkdir -p ~/.config/rex ~/.local/bin
rsync -av rex/init.lua ~/.config/rex/
rsync -av rex/bin/ ~/.local/bin/
