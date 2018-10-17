#!/bin/sh

set -ex

./configure --prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -lpthread"
make install prefix="$PREFIX"
