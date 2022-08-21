#!/usr/bin/env bash

# Exit on error. Append || true if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
#set -o xtrace

# Check that this script isn't being accidentally run outside of Docker
test -f /.dockerenv

# Make sure that the repo is already present in the right location
test -d ~/.local/share/chezmoi

# 1. Add Homebrew to the path
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 2
brew install chezmoi

# 3
chezmoi init

# 4
chezmoi apply

# Run the tests
cd ~/.local/share/chezmoi/tests

go test -count=1
