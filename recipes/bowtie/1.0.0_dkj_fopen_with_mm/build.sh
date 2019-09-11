#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n prefix="$PREFIX" CC="$GCC" CPP="$CXX" \
     CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

# There is no install target in the Makefile
mkdir -p "$PREFIX/bin"

cp bowtie "$PREFIX/bin/"
cp bowtie-build "$PREFIX/bin/"
cp bowtie-inspect "$PREFIX/bin/"
