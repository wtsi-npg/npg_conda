#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" \
            --libdir="$PREFIX/lib" \
            --with-include-path="$PREFIX/include" \
            --with-lib-path="$PREFIX/lib"

make -j $n LDFLAGS="-Wl,-rpath-link,$PREFIX/lib -Wl,--disable-new-dtags -L$PREFIX/lib"
make install prefix="$PREFIX"
