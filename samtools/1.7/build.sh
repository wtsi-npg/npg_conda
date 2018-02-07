#!/bin/sh

set -e

./configure --prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
