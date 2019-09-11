#!/bin/sh

set -ex

n="$CPU_COUNT"

./config --prefix="$PREFIX" \
         --libdir=lib \
         --openssldir="$PREFIX/etc/ssl" \
         --with-zlib-include="$PREFIX/include" \
         --with-zlib-lib="$PREFIX/lib" \
         shared zlib-dynamic

make -j $n CC="$GCC" \
     LDFLAGS="-Wl,-rpath-link,$PREFIX/lib -Wl,--disable-new-dtags"
make install prefix="$PREFIX"
