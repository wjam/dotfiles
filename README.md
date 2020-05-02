# Notes

## `bash/.bash_profile`
When bash is invoked as an interactive login shell, or as a non-interactive shell with the --login option,
it first reads and executes commands from the file /etc/profile, if that file exists.
After reading that file, it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile, in that order,
and reads and executes commands from the first one that exists and is readable

## `bash/.bashrc`
When an interactive shell that is not a login shell is started, bash reads and executes commands from /etc/bash.bashrc and ~/.bashrc

## Go & private Git servers
To get `go get` to work with private Git servers, like BitBucket server, `ssh-add` the SSH key and then
`git config --global.url url."ssh://git@server:port/".insteadOf "https://server/scm"`

# Installing
## Ubuntu
### fonts
`sudo apt install fonts-powerline`
### gnome-shell
Tick the following check box so that .bash_profile is actually run when running a Terminal
Edit > Preferences > Command > Run command as a login shell

## macOS
### Installation
```shell script
./install.sh
```
### Post installation
* Set up dock
    * Remove things to the right of the bar - everything apart from bin & downloads
* Tweak Finder
    * Add home directory to the side bar

# TODO
* Go through https://github.com/atomantic/dotfiles/blob/master/install.sh for things to auto-config for iterm2 etc
* How do other tools get added to man?
* CI
    * Ubuntu
    * Mac w/ sudo
    * Mac w/out sudo
    * https://help.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners
    * https://docs.travis-ci.com/user/reference/osx/
    * https://github.com/ashishb/dotfiles/blob/master/.travis.yml
    * https://medium.com/@sam_hosseini/build-a-macos-empire-a0c83879ac24
    * https://github.com/ashishb/dotfiles/tree/master/setup - separate installation
* Document how to visually verify the installation
* Document initial set up method - download zip from GitHub? Does it include the `.git` directory?
* Document key combinations for move to next monitor, etc
    * Hammerspoon config for mac
    * https://wiki.gnome.org/Design/OS/KeyboardShortcuts
