#!/bin/sh

set -ex

n="$CPU_COUNT"

rm -rf build
mkdir build

pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_TESTING=OFF \
      ..

make -j $n
make install

popd
