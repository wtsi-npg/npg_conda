#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-htslib=system CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
