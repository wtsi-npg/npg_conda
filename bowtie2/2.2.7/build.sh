#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`
make -j $n prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

# There is no install target in the Makefile
mkdir -p "$PREFIX/bin"

cp bowtie2 "$PREFIX/bin/"

cp bowtie2-build "$PREFIX/bin/"
cp bowtie2-build-l "$PREFIX/bin/"
cp bowtie2-build-s "$PREFIX/bin/"

cp bowtie2-inspect "$PREFIX/bin/"
cp bowtie2-inspect-l "$PREFIX/bin/"
cp bowtie2-inspect-s "$PREFIX/bin/"
