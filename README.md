# Set up
* Install [Homebrew](https://brew.sh/)
* Install Go
* Build https://github.com/justjanne/powerline-go
* Copy the `powerline-go` binary to /usr/local/bin
* Install custom fonts from https://github.com/powerline/fonts (LiberationMono)
** `brew tap homebrew/cask-fonts`
** `brew install homebrew/cask-fonts/font-liberation-mono-for-powerline`
* Configure iTerm2 (https://github.com/powerline/fonts/issues/44#issuecomment-300643099)

# Tools to install
* Git
* Go
* IntelliJ
* Atom
* awscli
* direnv
* terraform
* packer
* jq

## macOS specific
* iTerm2
* Homebrew
  * bash-completion
  * curl
  * htop
  * watch
  * git
  * readline? (.inputrc)

# Notes

## `bash/.bash_profile`
When bash is invoked as an interactive login shell, or as a non-interactive shell with the --login option,
it first reads and executes commands from the file /etc/profile, if that file exists.
After reading that file, it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile, in that order,
and reads and executes commands from the first one that exists and is readable

## `bash/.bashrc`
When an interactive shell that is not a login shell is started, bash reads and executes commands from /etc/bash.bashrc and ~/.bashrc

## macOS
Environment variables are also managed through:
* /etc/launchd.conf
* /etc/paths.d

# TODO
* Automate brew install stuff
* Go through https://github.com/atomantic/dotfiles/blob/master/install.sh for things to auto-config for iterm2 etc
