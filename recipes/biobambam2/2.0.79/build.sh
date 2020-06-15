#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" \
            --with-libmaus2="$PREFIX" \
            LDFLAGS="-L$PREFIX/lib"

make -j $n CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
