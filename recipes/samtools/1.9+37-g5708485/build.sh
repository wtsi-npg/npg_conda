#!/bin/sh

set -ex

n="$CPU_COUNT"

autoreconf

./configure --prefix="$PREFIX" \
            --with-htslib=system \
            --without-curses \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n AR="$AR"
make install prefix="$PREFIX"

mkdir p "$PREFIX/include/samtools"
cp "$SRC_DIR/"*.h "$PREFIX/include/samtools/"
cp "$SRC_DIR/libbam.a" "$PREFIX/lib"
