#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

pushd gtextutils
./configure --prefix="$PREFIX"
make -j $n
make install prefix="$PREFIX"
popd

pushd fastx_toolkit
./configure --prefix="$PREFIX"
make -j $n
make install prefix="$PREFIX"
popd
