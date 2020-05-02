#!/usr/bin/env bash

# Script used to set up an Ubuntu system

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

cwd=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function install_apt_packages() {
  # TODO check what actually should be installed through apt and what through brew
  # stable unchanging things via apt - fonts-powerline, stow
  # rapidly changing things via brew - awscli
  xargs --arg-file="${cwd}"/apt.txt sudo apt install
}

function install_linuxbrew() {
  # TODO need to be a suoder to do this? Check first?
  echo not implemented # TODO
  exit 1
}

function brew_bundle() {
  echo not implemented # TODO
  exit 1
}

function configure_gnome_shell() {
  echo not implemented # TODO
  exit 1
}

install_apt_packages
install_linuxbrew
brew_bundle

configure_gnome_shell
