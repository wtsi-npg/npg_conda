#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure prefix="$PREFIX" --without-python

make -j $n
make install
