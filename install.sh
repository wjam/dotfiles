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

cwd=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

rm -f ~/.bash_aliases ~/.bash_profile ~/.bashrc ~/.profile ~/.inputrc ~/.gitconfig ~/.hammerspoon

ln -s "${cwd}/bash/.bashrc" ~/.bashrc
ln -s "${cwd}/bash/.bash_profile" ~/.bash_profile
ln -s "${cwd}/bash/.bash_aliases" ~/.bash_aliases
ln -s "${cwd}/readline/.inputrc" ~/.inputrc
ln -s "${cwd}/git/.gitconfig" ~/.gitconfig
ln -s "${cwd}/hammerspoon" ~/.hammerspoon

os=$(uname -s)

case "${os}" in
  Darwin)
    # If brew isn't already installed, then this installation should fail
    brew bundle --file=${cwd}/packages/brewfile
    ;;
  Linux)
    if which apt > /dev/null; then
      xargs --arg-file=${cwd}/packages/apt.txt sudo apt install
    fi
    ;;
esac
