#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" \
            --without-fontconfig \
            --without-freetype \
            --without-jpeg \
            --without-liq \
            --with-png \
            --without-tiff \
            --without-webp \
            --without-xpm \
            --with-zlib

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX"
make install prefix="$PREFIX"
