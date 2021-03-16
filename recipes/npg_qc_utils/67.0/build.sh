#!/bin/sh

set -ex

n="$CPU_COUNT"

mkdir -p "$PREFIX/bin/"

pushd norm_fit
mkdir -p build
make -j $n CC="$GCC" \
     LIBPATH="-L$PREFIX/lib"
cp ./build/norm_fit "$PREFIX/bin/"
popd

pushd gt_utils
mkdir -p build
make -j $n  CC="$GCC" \
     CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-L$PREFIX/lib"
make install installdir="$PREFIX/bin/"
popd
