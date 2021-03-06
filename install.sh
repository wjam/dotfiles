#!/usr/bin/env bash

# Entry point for install dotfiles
# Delegates most work to O/S specific scripts before calling `stow`

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

function install_oh_my_zsh() {
  test -e "$HOME/.oh-my-zsh/oh-my-zsh.sh" || CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  test -e "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  test -e "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  test -e "$HOME/.oh-my-zsh/custom/plugins/zsh-auto-notify" || git clone https://github.com/MichaelAquilina/zsh-auto-notify.git "$HOME/.oh-my-zsh/custom/plugins/auto-notify"
}

dotfilesDir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

if [[ "${dotfilesDir}" != "${HOME}/.dotfiles" ]]; then
  echo "This should be checked out to ~/.dotfiles"
  exit 1
fi

os=$(uname -s)

case "${os}" in
  Darwin)
    # shellcheck source=setup/mac/install.sh
    source "${dotfilesDir}"/setup/mac/install.sh
    ;;
  Linux)
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
      # shellcheck source=setup/ubuntu/install.sh
      source "${dotfilesDir}"/setup/ubuntu/install.sh
    else
      echo "Unknown OS ${ID}"
      exit 1
    fi
    ;;
esac

brew bundle --file="${dotfilesDir}"/setup/Brewfile

install_oh_my_zsh

mkdir -p ~/.config
mkdir -p ~/.oh-my-zsh/completions

echo "If stow fails, then you need to delete the existing files"
stow -d "${dotfilesDir}" zsh git readline path hammerspoon

stow -d "${dotfilesDir}" -t "$HOME/.config" config
stow -d "${dotfilesDir}" -t "$HOME/.oh-my-zsh/completions" zsh-completions
stow -d "${dotfilesDir}" -t "$HOME/.oh-my-zsh/themes" zsh-themes

# TODO move aws_finder completion to a custom plugin?
