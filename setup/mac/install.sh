#!/usr/bin/env bash

# Script used to set up a macOS system - either as an admin or non-admin

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

macDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function is_sudoer() {
  # TODO use what brew does for its check?
  admin_group=$(groups | grep "\<admin\>" || true)
  if [ "$admin_group" != "" ]; then
    return 0
  fi
  return 1
}

function wait_for_app_store_login_confirmation() {
  echo "Log in to the Apple App Store and come back to here"
  read -r -p "Press enter to continue"
}

function is_xcode_installed() {
  xcode=$(xcode-select -p 2>/dev/null || true)
  if [ "$xcode" != "" ]; then
    return 0
  fi
  return 1
}

function check_xcode_installed() {
  if ! is_xcode_installed; then
    echo "xcode-select --install must be installed first"
    exit 1
  fi
}

function install_brew() {
  # Note that default installation of brew will install xcode CLI tools
  [[ -f /usr/local/bin/brew ]] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

function install_brew_locally() {
  mkdir -p ~/dev/brew
  [[ -f ~/dev/brew/bin/brew ]] || curl -fL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/dev/brew
  export PATH="$HOME/dev/brew/bin:$PATH" # TODO check that it isn't already on the path - verify whether exported variables survive outside of shell?
}

function brew_bundle_admin() {
  brew bundle --file="${macDir}"/Brewfile-admin
}

function mas_uninstall() {
  installed=$(mas list | grep "$1" || true)
  if [ "$installed" != "" ]; then
    mas uninstall "$1"
  fi
}

function uninstall_unwanted_default_apps() {
  # TODO test this deletes when preinstalled
  mas_uninstall 409203825 # Numbers
  mas_uninstall 409201541 # Pages
  mas_uninstall 682658836 # GarageBand
  mas_uninstall 408981434 # iMovie
}

# Check whether tools that can only be installed as admin are present
function check_admin_tools_installed() {
  if ! command -v docker &>/dev/null; then
    echo "docker not installed"
    exit 1
  fi
  if ! command -v java &>/dev/null; then
    echo "java not installed"
    exit 1
  fi
}

function brew_bundle_mac() {
  # TODO add cask "keeweb" or cask "keepassxc"
  brew bundle --file="${macDir}"/Brewfile-mac
}

function brew_bundle() {
  brew bundle --file="${macDir}"/../Brewfile
}

function configure_finder() {
  # TODO defaults write com.apple.finder AppleShowAllFiles YES; # show hidden files
  # TODO defaults write NSGlobalDomain AppleShowAllExtensions -bool true; # show all file extensions
  # Set the default view to be list
  defaults write com.apple.Finder FXPreferredViewStyle Nlsv
  # Show path bar in Finder
  defaults write com.apple.finder ShowPathbar -bool true
  # Don't show tags in Finder
  defaults write com.apple.finder SidebarTagsSctionDisclosedState -bool false
  # Get Finder to reload its configuration
  killall Finder
}

function configure_dock() {
  # TODO defaults write com.apple.dock persistent-apps -array; # remove icons in Dock - what about finder, app store
  # Don't show recent applications in dock
  defaults write com.apple.dock "show-recents" -bool false
  # Set size of icons in dock
  defaults write com.apple.dock "tilesize" -int 45
  # Get Dock to reload its configuration
  killall Dock
}

function configure_iterm2() {
  # Specify the preferences directory
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/.dotfiles/iterm"
  # Tell iTerm2 to use the custom preferences in the directory
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
}

function configure_keyboard() {
  # Stop inserting a "." when accidentally typing "  "
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
}

function change_to_zsh() {
  chsh -s /bin/zsh
}

if is_sudoer; then
  wait_for_app_store_login_confirmation
  install_brew
  brew_bundle_admin
  uninstall_unwanted_default_apps
else
  check_xcode_installed
  check_admin_tools_installed
  install_brew_locally
fi
brew_bundle_mac
brew_bundle
configure_finder
configure_dock
configure_iterm2
configure_keyboard

change_to_zsh

# TODO add comment about reading manual steps?
