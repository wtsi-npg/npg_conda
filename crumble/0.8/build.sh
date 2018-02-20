#!/bin/sh

set -e

make prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"
cp crumble "$PREFIX/bin/"
