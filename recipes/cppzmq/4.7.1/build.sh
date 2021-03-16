#!/bin/sh

set -ex

n="$CPU_COUNT"

mkdir build
cd build

export CXXFLAGS="-I$PREFIX/include"

cmake .. \
      -D CMAKE_INSTALL_PREFIX="$PREFIX" \
      -D CPPZMQ_BUILD_TESTS=OFF # See https://github.com/zeromq/cppzmq/issues/457

make VERBOSE=1 -j "$n"
make install
