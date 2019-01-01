# Set up
* Install [Homebrew](https://brew.sh/)
* Install Go
* Build https://github.com/justjanne/powerline-go
* Copy the `powerline-go` binary to /usr/local/bin
* Install custom fonts from https://github.com/powerline/fonts (LiberationMono)
  * `brew tap homebrew/cask-fonts`
  * `brew install homebrew/cask-fonts/font-liberation-mono-for-powerline`
* Configure iTerm2 (https://github.com/powerline/fonts/issues/44#issuecomment-300643099)

# Tools to install
* Git
* Go
* IntelliJ
* Atom
* terraform
* packer

## macOS specific
* [iTerm2](https://www.iterm2.com/)
* [Homebrew](https://brew.sh/)

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

## Ubuntu
### fonts
`sudo apt install fonts-powerline`
### gnome-shell
Tick the following check box so that .bash_profile is actually run when running a Terminal
Edit > Preferences > Command > Run command as a login shell

# TODO
* Automate brew install stuff
* Go through https://github.com/atomantic/dotfiles/blob/master/install.sh for things to auto-config for iterm2 etc
* Remove `/usr/local/opt/go@1.10/bin` reference from `.bashrc` and use direnv instead
* Try replacing shiftit with hammerspoon
  * Test next/previous screen with maximised and normal screen
  * Ctrl+Alt+Meta - left, up, down, right
