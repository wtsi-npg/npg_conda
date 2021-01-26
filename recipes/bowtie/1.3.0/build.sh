#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n prefix="$PREFIX" CC="$GCC" CPP="$CXX" \
     EXTRA_CXXFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

# There is no install target in the Makefile
mkdir -p "$PREFIX/bin"

cp bowtie "$PREFIX/bin/"

cp bowtie-align-l "$PREFIX/bin/"
cp bowtie-align-s "$PREFIX/bin/"
		 
cp bowtie-build "$PREFIX/bin/"
cp bowtie-build-l "$PREFIX/bin/"
cp bowtie-build-s "$PREFIX/bin/"
		 
cp bowtie-inspect "$PREFIX/bin/"
cp bowtie-inspect-l "$PREFIX/bin/"
cp bowtie-inspect-s "$PREFIX/bin/"
