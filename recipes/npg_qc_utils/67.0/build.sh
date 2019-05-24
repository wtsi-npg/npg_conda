#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

pushd npg_qc_utils

pushd norm_fit
mkdir -p build
make -j $n INCLUDES="-I. -I$PREFIX/include" LIBPATH="-L$PREFIX/lib"
cp ./build/norm_fit "$PREFIX/bin/"
popd

pushd gt_utils
mkdir -p build
make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install installdir="$PREFIX/bin"
popd

popd
