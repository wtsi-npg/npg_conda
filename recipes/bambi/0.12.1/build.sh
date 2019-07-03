#!/bin/sh

set -e

autoreconf -fi

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" --with-htslib="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
