#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure prefix="$PREFIX" --with-zlib="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make -j $n
make install prefix="$PREFIX"
