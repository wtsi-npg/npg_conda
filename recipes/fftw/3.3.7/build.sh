#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX"
make -j $n
make install prefix="$PREFIX"

./configure --prefix="$PREFIX" --enable-float
make -j $n
make install prefix="$PREFIX"
