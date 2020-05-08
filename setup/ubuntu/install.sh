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

ubuntuDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function install_apt_packages() {
  xargs --arg-file="${ubuntuDir}"/apt.txt sudo apt install
}

function install_linuxbrew() {
  [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  # TODO check that it isn't already on the path - verify whether exported variables survive outside of shell?
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

function brew_bundle_linux() {
  brew bundle --file="$ubuntuDir"/Brewfile-linux
}

function brew_bundle() {
  brew bundle --file="$ubuntuDir"/../Brewfile
}

function install_extension() {
  file=$(mktemp)
  trap "rm -f $file" 0 2 3 15
  curl -Lfs "$1" -o "${file}"
  gnome-extensions install -f "${file}"
  gnome-extensions enable "$(unzip -p "${file}" metadata.json | jq -r '.uuid')"
}

function set_putWindow_pref() {
  gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas set org.gnome.shell.extensions.org-lab21-putwindow "$1" "$2"
}

function configure_gnome_shell() {
  [[ "$(gnome-extensions version)" == 3.36* ]] || (echo "Unsupported version of Gnome!" && exit 1)

  # caffeine
  install_extension https://extensions.gnome.org/download-extension/caffeine%40patapon.info.shell-extension.zip?version_tag=14531
  # putWindows
  install_extension https://extensions.gnome.org/download-extension/putWindow%40clemens.lab21.org.shell-extension.zip?version_tag=10507

  # configure putWindows
  # keep window on current screen?
  mash="<Super><Primary><Alt>"
  # {north, south, east, west} height - 50
  set_putWindow_pref north-height-0 50
  set_putWindow_pref north-height-1 50
  set_putWindow_pref north-height-2 50
  set_putWindow_pref south-height-0 50
  set_putWindow_pref south-height-1 50
  set_putWindow_pref south-height-2 50
  set_putWindow_pref left-side-widths-0 50
  set_putWindow_pref left-side-widths-1 50
  set_putWindow_pref left-side-widths-2 50
  set_putWindow_pref right-side-widths-0 50
  set_putWindow_pref right-side-widths-1 50
  set_putWindow_pref right-side-widths-2 50

  # move to top right corner - mash+2
  set_putWindow_pref put-to-corner-ne-enabled 1
  set_putWindow_pref put-to-corner-ne "['${mash}2']"
  # move to top left corner - mash+1
  set_putWindow_pref put-to-corner-nw-enabled 1
  set_putWindow_pref put-to-corner-nw "['${mash}1']"
  # move to bottom right corner - mash+4
  set_putWindow_pref put-to-corner-se-enabled 1
  set_putWindow_pref put-to-corner-se "['${mash}4']"
  # move to bottom left corner - mash+3
  set_putWindow_pref put-to-corner-sw-enabled 1
  set_putWindow_pref put-to-corner-sw "['${mash}3']"
  # move to top - mash+up
  set_putWindow_pref put-to-side-n-enabled 1
  set_putWindow_pref put-to-side-n "['${mash}Up']"
  # move to right - mash+right
  set_putWindow_pref put-to-side-e-enabled 1
  set_putWindow_pref put-to-side-e "['${mash}Right']"
  # move to bottom - mash+down
  set_putWindow_pref put-to-side-s-enabled 1
  set_putWindow_pref put-to-side-s "['${mash}Down']"
  # move to left - mash+left
  set_putWindow_pref put-to-side-w-enabled 1
  set_putWindow_pref put-to-side-w "['${mash}Left']"
  # move to center/maximize - mash+c
  set_putWindow_pref put-to-center-enabled 1
  set_putWindow_pref put-to-center "['${mash}c']"
  # disable move to configured location
  set_putWindow_pref put-to-location-enabled 0
  # move to the right screen - mash+n
  set_putWindow_pref put-to-right-screen-enabled 1
  set_putWindow_pref put-to-right-screen "['${mash}n']" # TODO test
  # move to the left screen - mash+p
  set_putWindow_pref put-to-left-screen-enabled 1
  set_putWindow_pref put-to-left-screen "['${mash}p']"  # TODO test

  # disable move focus
  set_putWindow_pref move-focus-enabled 0

  # Reload gnome-shell to load the new extensions
  killall -3 gnome-shell
}

function set_terminal_profile_pref() {
  profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d\' -f2)
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$profile"/ "$1" "$2"
}

function configure_gnome_terminal() {
  # open new terminals in tabs ?

  set_terminal_profile_pref font 'Liberation Mono 10'
  set_terminal_profile_pref use-system-font false
  set_terminal_profile_pref default-size-columns 124
  set_terminal_profile_pref default-size-rows 30
  set_terminal_profile_pref scrollback-unlimited true
  set_terminal_profile_pref login-shell true
}

install_apt_packages
install_linuxbrew # TODO depends on sudo access
brew_bundle_linux
brew_bundle

configure_gnome_shell
configure_gnome_terminal
