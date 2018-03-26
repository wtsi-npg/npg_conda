#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" \
            --without-fontconfig \
            --without-freetype \
            --without-jpeg \
            --without-liq \
            --with-png \
            --without-tiff \
            --without-webp \
            --without-xpm

make -j $n
make install prefix="$PREFIX"
