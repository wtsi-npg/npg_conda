#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure \
  --prefix="$PREFIX" \
  CPPFLAGS="-I$PREFIX/include" \
  LDFLAGS="-Wl,-rpath-link,$PREFIX/lib -Wl,--disable-new-dtags -L$PREFIX/lib"

make -j "$n"
make install
