#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" --with-htslib="$PREFIX"

make -j $n
make install prefix="$PREFIX"
