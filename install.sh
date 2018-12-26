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

rm -f ~/.bash_aliases ~/.bash_profile ~/.bashrc ~/.profile ~/.inputrc ~/.gitconfig

ln -s "${cwd}/bash/.bashrc" ~/.bashrc
ln -s "${cwd}/bash/.bash_profile" ~/.bash_profile
ln -s "${cwd}/bash/.bash_aliases" ~/.bash_aliases
ln -s "${cwd}/readline/.inputrc" ~/.inputrc
ln -s "${cwd}/git/.gitconfig" ~/.gitconfig
