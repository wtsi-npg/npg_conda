#!/bin/sh

set -ex

n="$CPU_COUNT"

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make -j $n install CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
