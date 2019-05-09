#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" --with-zlib="$PREFIX" --with-libcurl="$PREFIX"

make -j $n CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-Wl,-rpath-link,$PREFIX/lib -Wl,--disable-new-dtags -L$PREFIX/lib"
make install prefix="$PREFIX"
