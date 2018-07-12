#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" --libdir="$PREFIX/lib"

make -j $n
make install prefix="$PREFIX"
