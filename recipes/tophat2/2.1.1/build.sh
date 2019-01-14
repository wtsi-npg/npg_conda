#!/bin/sh

set -e

n=1

# Using --with-boost avoids picking up /usr/lib boost, if present.
./configure --prefix="$PREFIX" --with-boost="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n
make install prefix="$PREFIX"
