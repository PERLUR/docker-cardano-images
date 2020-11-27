#!/bin/sh

# force systemd off until there's a solution to
# https://github.com/haskell/cabal/issues/5444

set -eux

root="$(dirname "$(dirname "$(realpath "$0")")")"

cd "${root}"

sed '/plugins\/scribe-systemd/d' -i cabal.project
echo "" >> cabal.project
echo "flags: -systemd" >> cabal.project

if [ -e cabal.project.freeze ] ; then
    cp cabal.project.freeze cabal.nosystemd.project.freeze
fi