#!/bin/sh

set -e

n=$CPU_COUNT

export LD_LIBRARY_PATH="$PREFIX/lib64:$LD_LIBRARY_PATH"
./bootstrap --prefix="$PREFIX" --parallel=$n

make -j $n
make install prefix="$PREFIX"
