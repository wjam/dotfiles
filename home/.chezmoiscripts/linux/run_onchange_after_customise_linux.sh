#!/usr/bin/env bash

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

# No brew added to path as `awscli` installs glib which includes its own version of `gsettings` which doesn't read from the standard location

function set_setting_pref() {
  # `awscli` installs glib which includes its own version of `gsettings` which doesn't read from the standard location
  /usr/bin/gsettings set org.gnome.Terminal.Legacy.Settings "$1" "$2"
}
