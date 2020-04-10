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

if [[ "${cwd}" != "${HOME}/.dotfiles" ]]; then
  echo "This should be checked out to ~/.dotfiles"
  exit 1
fi

os=$(uname -s)

case "${os}" in
  Darwin)
    if ! command docker || ! command java; then
        brew bundle --file="${cwd}"/packages/Brewfile-admin
    fi
    # If brew isn't already installed, then this installation should fail
    brew bundle --file="${cwd}"/packages/Brewfile
    # shellcheck source=packages/mac-config.sh
    source "${cwd}"/packages/mac-config.sh
    ;;
  Linux)
    if which apt > /dev/null; then
      xargs --arg-file="${cwd}"/packages/apt.txt sudo apt install
    fi
    ;;
esac

echo "If stow fails, then you need to delete the existing files"
stow -d ${cwd} bash git readline path


case "${os}" in
  Darwin)
    stow -d ${cwd} hammerspoon
    ;;
esac
