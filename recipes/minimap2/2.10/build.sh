#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"
cp minimap2 "$PREFIX/bin/"

mkdir -p "$PREFIX/share/man/man1"
cp minimap2.1 "$PREFIX/share/man/man1/"
