#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

make -j $n prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

# There is no install target in the Makefile
mkdir -p "$PREFIX/bin"

cp bowtie "$PREFIX/bin/"
cp bowtie-build "$PREFIX/bin/"
cp bowtie-inspect "$PREFIX/bin/"
