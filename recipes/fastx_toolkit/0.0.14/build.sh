#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd gtextutils
./configure --prefix="$PREFIX"
make -j "$n" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
popd

pushd fastx_toolkit
./configure --prefix="$PREFIX"
make -j "$n" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
popd
