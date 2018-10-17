#!/bin/sh

set -ex

n="$CPU_COUNT"

autoreconf -fi
./configure --prefix="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include" \
            LDFLAGS="-L$PREFIX/lib"

make -j $n CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-Wl,--disable-new-dtags -L$PREFIX/lib"
make install prefix="$PREFIX"

