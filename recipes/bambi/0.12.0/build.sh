#!/bin/sh

set -ex

autoreconf -fi

n="$CPU_COUNT"

CPPFLAGS="-I$PREFIX/include" LDFLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib" \
        ./configure --prefix="$PREFIX" --with-htslib="$PREFIX"

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
