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

# Example markdown pages
# https://pandoc.org/demo/pandoc.1.md
# https://gist.github.com/eddieantonio/55752dd76a003fefb562

cwd=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

for i in {1..9} ; do
  rm  -f "${cwd}"/man${i}/*.${i}

  find "${cwd}"/ -name "*.${i}.md" -exec sh -c '
    mkdir -p "${1}"/man${2}
    filename=$(basename -- "${3}")
    without_extension="${filename%.*}"
    pandoc -s -t man "${3}" -o ${1}/man${2}/"${without_extension}"
  ' sh "${cwd}" ${i} {} \;
done
