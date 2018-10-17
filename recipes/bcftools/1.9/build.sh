#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" --with-htslib="$PREFIX"

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
