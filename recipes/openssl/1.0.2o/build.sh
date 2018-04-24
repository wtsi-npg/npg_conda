#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./config --prefix="$PREFIX" \
         --libdir=lib \
         --openssldir="$PREFIX/etc/ssl" \
         --with-zlib-include="$PREFIX/include" \
         --with-zlib-lib="$PREFIX/lib" \
         shared zlib-dynamic

make -j $n
make install prefix="$PREFIX"
