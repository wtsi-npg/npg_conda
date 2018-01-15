#!/bin/sh

set -e

./configure --prefix="$PREFIX" --enable-libcurl CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"

cd ./plugins
make install prefix="$PREFIX" CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
