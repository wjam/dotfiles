# Notes

## Tools installed via brew

| Name           | Description                                 |
|----------------|---------------------------------------------|
| fzf            | Used by ZSH plugins                         |
| dive           | Browse contents of Docker images            |
| jq             | Manipulating JSON                           |
| direnv         | Per-directory environment-configuration     |
| pandoc         | Generating man from markdown                |
| ipcalc         | Working out CIDR ranges                     |
| powerline-go   | Advanced command prompt                     |
| kubernetes-cli | kubectl                                     |
| kubectx        | Switch between Kubernetes contexts          |
| stern          | Tail multiple Kubernetes pods               |
| k9s            | Visualise Kubernetes cluster in CLI         |
| pgcli          | PostgreSQL tool                             |
| pv             | Monitor the progress of data through a pipe |

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

## Useful commands
* Why has Homebrew installed a dependency - `brew uses --recursive --installed formulae-name`
* Remove dependencies automatically installed but no longer needed - `brew autoremove`
* Slowly display a file - `cat filename | pv --quiet --line-mode --rate-limit 5`

## Workarounds
* Unable to compile Go programs on Linux using Go installed using Homebrew (`cgo: C compiler "gcc-5" not found: exec: "gcc-5": executable file not found in $PATH`) - see `home/private_dot_config/go/env` (https://stackoverflow.com/questions/59227456/go-1-13-gcc-5-not-in-path)

# Installing

## Initial per-O/S steps
### macOS
1. Sign in to the app store
2. Install all updates
3. Launch the app store and sign in

### Ubuntu
1. Install [packages required by Homebrew](https://docs.brew.sh/Homebrew-on-Linux#requirements)

## Common steps
1. [Install Homebrew](https://brew.sh/) - either at the standard location (`/usr/local/bin` or `/home/linuxbrew/.linuxbrew/bin`)
   or at `$HOME/dev/brew`
2. Add Homebrew to the path (`eval "$(/path/to/homebrew/install/bin/brew shellenv)"`)
3. `brew install chezmoi`
4. `chezmoi init wjam`
5. `chezmoi apply`

## Ubuntu post installation
TODO

## macOS post installation
* Create two shortcuts (app added with Monterey): `focus-mode` (turn on do not disturb), and `unfocus-mode` (turn off do not disturb)
* Add 'Home' network location & create `~/.hammerspoon/ssid.json` like `{"home": "SSIDOfHomeNetwork"}`
* Tweak Finder
  * Add home directory to the sidebar
* Settings > Display > Resolution: Scaled (More Space)
* Settings > Display > Show mirroring options in the menu bar when available
* Start hammerspoon
  * launch at login
  * enable accessibility
* Start Stats and select start at login
* Start JetBrains toolbox
  * generate shell scripts & set to `~/bin`
* Show sound in menu bar
* Settings > Keyboard > 'Touch Bar shows': 'F1, F2, etc. Keys'
* KeeWeb
  * Security & Privacy > Privacy > Accessibility
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

# Testing
Run the Go tests inside a Docker container with Homebrew, etc installed:
```shell
docker run -v $(pwd):/home/docker/.local/share/chezmoi -it $(docker build -q .) /home/docker/.local/share/chezmoi/testing.sh
```

# TODO
* This README
* CI
  1. cache homebrew cache dir (`~/.cache/Homebrew` on Linux)
  2. run and install chezmoi in headless mode
  3. verify it's working
    * common tools work?
* Make hammerspoon bluetooth script remember what the state was when resuming.
  * `blueutil --power` - https://www.hammerspoon.org/docs/hs.settings.html to save the value between sleeping - example: https://github.com/cmsj/hammerspoon-config/blob/master/hueMotionSensor.lua
* Find out why meeting interruption stuff isn't working when streamdeck is connected
* Find something cask-like for Ubuntu
