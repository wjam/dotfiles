# Set up for mac
* Install [iTerm2](https://www.iterm2.com/)
* Install [Homebrew](https://brew.sh/)
* Run `./install.sh`
* Restart iTerm2

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

## Ubuntu
### fonts
`sudo apt install fonts-powerline`
### gnome-shell
Tick the following check box so that .bash_profile is actually run when running a Terminal
Edit > Preferences > Command > Run command as a login shell

## macOS
### Post installation
* Uninstall unused default apps
    * Numbers
    * Pages
    * GarageBand
    * iMovie
* Set up dock
    * Untick 'show recent applications in dock'
    * Size
* Install software managed through the App Store
    * Slack
    * Microsoft Remote Desktop
* Tweak Finder
    * Add home directory to the side bar
    * Hide tags
* iTerm2
    * Fix cmd+{left,right} due to iTerm swallowing all command key presses
        * Remove next & previous tab key bindings as these are bound to cmd+{left,right}
        * Add cmd+left (hex code 0x01) & cmd+right (hex code 0x05) to `profile` > `default` > `keys`
    * Change the theme to compact (`Appearance` > `General`)


# TODO
* Go through https://github.com/atomantic/dotfiles/blob/master/install.sh for things to auto-config for iterm2 etc
* How do other tools get added to man?
