#!/usr/bin/env bash

# This script is designed to clean up GitHub macOS runners that come with things not installed or upgradable via
# Homebrew

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

brew list go && brew uninstall go
rm /usr/local/bin/go || true
rm /usr/local/bin/gofmt || true

brew list -1 | grep '^python@' | cut -d@ -f2 | while IFS= read -r ver; do
  brew uninstall --ignore-dependencies "python@$ver"
  rm /usr/local/bin/2to3{,"-$ver"} || true
  rm /usr/local/bin/{idle,pydoc}{3,"$ver"} || true
  rm /usr/local/bin/{python3,"python$ver"}{,-config} || true
done
