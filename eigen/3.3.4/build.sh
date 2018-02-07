#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make -j $n install
