#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

pushd samtools
make -j $n
popd

pushd pb_calibration
pushd src

autoreconf -fi
./configure --prefix="$PREFIX" --with-io_lib="$PREFIX" --with-samtools="$SRC_DIR/samtools"
make CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install

popd
popd
