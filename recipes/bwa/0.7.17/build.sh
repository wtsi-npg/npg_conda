#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"
cp bwa "$PREFIX/bin/"

mkdir -p "$PREFIX/share/man/man1"
cp bwa.1 "$PREFIX/share/man/man1/"
