#!/bin/bash

set -exuo pipefail

mkdir build
cd build

export CXXFLAGS="-I$PREFIX/include -fPIC"
export LDFLAGS="-L$BUILD_PREFIX/lib -lrt"

cmake .. \
      -D CMAKE_INSTALL_PREFIX="$PREFIX" \
      -D BOOST_ROOT="$PREFIX" \
      -D SNAPPY_ROOT_DIR="$PREFIX" \
      -D CMAKE_BUILD_TYPE="RelWithDebInfo" \
      -D CMAKE_AR="$AR"

make -j "$CPU_COUNT" VERBOSE=1 CXX_FLAGS="$CXXFLAGS"
make install
