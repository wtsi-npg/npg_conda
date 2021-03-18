#!/bin/sh

set -ex

cd c++

autoreconf -i

LD_LIBRARY_PATH=$PREFIX/lib ./configure --prefix="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include" \
            LDFLAGS="-L$PREFIX/lib"

make clean

make install prefix="$PREFIX"
