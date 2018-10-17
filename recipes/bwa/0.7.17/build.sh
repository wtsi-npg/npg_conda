#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"
cp bwa "$PREFIX/bin/"

mkdir -p "$PREFIX/share/man/man1"
cp bwa.1 "$PREFIX/share/man/man1/"
