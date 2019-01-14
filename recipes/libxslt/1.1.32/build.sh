#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure prefix="$PREFIX" --without-python

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install
