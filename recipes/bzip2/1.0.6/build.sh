#!/bin/sh

set -ex

n="$CPU_COUNT"

CFLAGS="$CFLAGS -Wall -Winline -O2 -g -D_FILE_OFFSET_BITS=64 -fPIC"

make -j $n CC="$GCC" PREFIX="$PREFIX" CFLAGS="$CFLAGS"
make PREFIX="$PREFIX" install
make -f Makefile-libbz2_so  CC="$GCC" PREFIX="$PREFIX" CFLAGS="$CFLAGS"

cp -a libbz2.so* "$PREFIX/lib/"
ln -s "$PREFIX/lib/libbz2.so.1.0" "$PREFIX/lib/libbz2.so"
