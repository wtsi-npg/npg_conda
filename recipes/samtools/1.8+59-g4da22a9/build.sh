#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

autoreconf
./configure --prefix="$PREFIX" \
            --with-htslib=system \
            --without-curses \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n
make install prefix="$PREFIX"
