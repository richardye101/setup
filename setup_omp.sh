#!/bin/bash
# Installs the omp config. Install omp first.
# Sign in afterwards (`omp`, then /login), and put your GitHub token in
# ~/.omp/agent/mcp.json where it says REPLACE_WITH_GITHUB_PAT.
# The AIOS providers in models.yml need the loopback proxy on port 4019 to be running.
cd "$(dirname "$0")" || exit 1

mkdir -p ~/.omp/agent
rsync -av omp/agent/ ~/.omp/agent/
