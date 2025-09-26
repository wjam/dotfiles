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

# Make sure that the repo is already present in the right location
test -d ~/.local/share/chezmoi

# Make sure .local/share is owned by _this_ user
find ~/.local/share -maxdepth 0 \! -user "$(whoami)" -type d -exec sudo chown "$(whoami)" {} \;

## Ensure Homebrew is on the path
if ! command -v brew > /dev/null; then
  if [[ -e $HOME/dev/brew/bin ]]; then
    eval "$("$HOME"/dev/brew/bin/brew shellenv)"
  elif [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

brew update

# Install chezmoi
if ! command -v chezmoi > /dev/null; then
  brew install chezmoi
fi

# Apply chezmoi
chezmoi init "$@"
chezmoi apply

# Run the tests
cd ~/.local/share/chezmoi/tests

go test -count=1
