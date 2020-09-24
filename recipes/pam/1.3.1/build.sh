#!/bin/sh

set -ex

n="$CPU_COUNT"

CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" \
        ./configure prefix="$PREFIX" \
        --includedir="$PREFIX/include/security"

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make check
make install

