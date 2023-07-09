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

BASEDIR=$(dirname "$0")

data=$(cat "$BASEDIR"/home/.chezmoidata.json)

function update() {
  local value="$1"
  local infix="$2"

  currentVersion="$(echo "$data" | jq --raw-output ".$value")"
  latestVersion="$(curl --show-error --silent --fail --location "https://api.github.com/repos/$infix/releases/latest" | jq -r '.tag_name')"

  if [[ "v$currentVersion" != "$latestVersion" ]]; then
    data="$(echo "$data" | jq --arg v "$latestVersion" --raw-output ".$value = \$v")"
    echo "$infix $currentVersion $latestVersion"
  fi
}

update aws_finder_version wjam/aws_finder
update docker_buildx_version docker/buildx
update docker_compose_version docker/compose

echo "$data" > "$BASEDIR"/home/.chezmoidata.json
