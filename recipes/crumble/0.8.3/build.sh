#!/bin/sh

set -e

autoreconf -fi
./configure
make prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"


mkdir -p "$PREFIX/bin"
cp crumble "$PREFIX/bin/"
