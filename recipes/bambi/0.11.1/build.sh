#!/bin/sh

set -ex

autoreconf -fi

n="$CPU_COUNT"

./configure --prefix="$PREFIX" --with-htslib="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
