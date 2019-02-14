#!/bin/sh

set -ex

n="$CPU_COUNT"

autoreconf

CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" \
        ./configure --prefix="$PREFIX" \
        --with-htslib=system \
        --without-curses

make -j $n AR="$AR" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"

mkdir p "$PREFIX/include/samtools"
cp "$SRC_DIR/"*.h "$PREFIX/include/samtools/"
cp "$SRC_DIR/libbam.a" "$PREFIX/lib"
