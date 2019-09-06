#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure prefix="$PREFIX" \
            --with-gnutls="$PREFIX" \
            --with-zlib="$PREFIX" \
            --without-ssl \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n LDFLAGS="-Wl,-rpath-link,$PREFIX/lib -Wl,--disable-new-dtags -L$PREFIX/lib"
make install prefix="$PREFIX"
