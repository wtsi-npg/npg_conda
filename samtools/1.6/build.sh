#!/bin/sh

set -e

./configure --prefix="$PREFIX" CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
