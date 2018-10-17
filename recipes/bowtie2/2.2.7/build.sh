#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

# There is no install target in the Makefile
mkdir -p "$PREFIX/bin"

cp bowtie2 "$PREFIX/bin/"

cp bowtie2-align-l "$PREFIX/bin/"
cp bowtie2-align-s "$PREFIX/bin/"

cp bowtie2-build "$PREFIX/bin/"
cp bowtie2-build-l "$PREFIX/bin/"
cp bowtie2-build-s "$PREFIX/bin/"

cp bowtie2-inspect "$PREFIX/bin/"
cp bowtie2-inspect-l "$PREFIX/bin/"
cp bowtie2-inspect-s "$PREFIX/bin/"
