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
```shell script
./install.sh
```
## Ubuntu post installation
TODO

## macOS post installation
* Create two shortcuts (app added with Monterey): `focus-mode` (turn on do not disturb), and `unfocus-mode` (turn off do not disturb)
* Add 'Home' network location & create `~/.hammerspoon/ssid.json` like `{"home": "SSIDOfHomeNetwork"}`
* Tweak Finder
  * Add home directory to the side bar
* Settings > Display > Resolution: Scaled (More Space)
* Settings > Display > Show mirroring options in the menu bar when available
* Start hammerspoon
  * launch at login
  * enable accessibility
* Start MenuMeters
  * cpu - graph, show sum of all cores
  * no disk
  * network - graph and throughput
* Start JetBrains toolbox
  * generate shell scripts & set to `~/bin`
* Show sound in menu bar
* Settings > Keyboard > 'Touch Bar shows': 'F1, F2, etc. Keys'
* KeeWeb
  * Security & Privacy > Privacy > Accessibility
* Power source - show percentage
* Settings > Date & Time > Clock: Show date
* Neuter Spotlight (stop it crawling & using results from files being changed on disk)
  * Settings > Spotlight:
    * Search Results:
      * Applications
      * Calculator
      * Conversion
      * System Preferences
    * Privacy:
      * Add dev folder, e.g. `/Users/wjam/dev`

# TODO
* CI?
* Find something cask-like for Ubuntu
* Test multi-tab history
* rustc works but cargo completion doesn't
* Why Homebrew installed a dependency - `brew uses --recursive --installed formulae-name`
* Remove dependencies automatically installed but no longer needed - `brew autoremove`
