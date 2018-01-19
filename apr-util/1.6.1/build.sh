#!/bin/sh

set -e

CC="$GCC -m64" ./configure --prefix="$PREFIX" --with-apr="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
