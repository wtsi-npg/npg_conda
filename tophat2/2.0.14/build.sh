#!/bin/sh

set -e

# Using --with-boost avoids picking up /usr/lib boost, if present.
./configure --prefix="$PREFIX" --with-boost="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
