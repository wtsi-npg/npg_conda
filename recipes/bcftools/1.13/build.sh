#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" --with-htslib="$PREFIX" \
  CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j "$n" 
make install prefix="$PREFIX"
