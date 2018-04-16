#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure prefix="$PREFIX" \
            --with-gnutls="$PREFIX" \
            --with-zlib="$PREFIX" \
            --without-ssl \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make -j $n
make install prefix="$PREFIX"
