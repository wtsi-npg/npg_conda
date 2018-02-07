#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

CC="gcc -m64" ./configure --prefix="$PREFIX"

make -j $n
make install prefix="$PREFIX"
