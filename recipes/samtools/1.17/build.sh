#!/bin/sh

set -ex

n="$CPU_COUNT"

autoheader
autoconf

./configure --prefix="$PREFIX" \
            --with-htslib=system \
            --without-curses \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
        
make -j "$n" AR="$AR"
make install prefix="$PREFIX"
