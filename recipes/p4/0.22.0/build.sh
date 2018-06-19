#!/bin/sh

set -e

perl Build.PL --install_base="$PREFIX"
./Build install

chmod -R u+w "$PREFIX"
