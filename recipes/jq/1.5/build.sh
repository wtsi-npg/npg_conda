#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" --disable-maintainer-mode

make -j $n LDFLAGS=-all-static
make install prefix="$PREFIX"
