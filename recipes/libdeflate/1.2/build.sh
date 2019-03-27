#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
