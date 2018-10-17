#!/bin/sh

set -ex

n="$CPU_COUNT"

prefix="$PREFIX" CC="$GCC" ./configure
make -j $n CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install
