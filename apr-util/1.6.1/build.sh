#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

CC="gcc -m64" ./configure --prefix="$PREFIX" --with-apr="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
