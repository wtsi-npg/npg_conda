#!/bin/sh

set -ex

n="$CPU_COUNT"

mkdir build
cd build

export CXXFLAGS="-I$PREFIX/include"

cmake -G "Unix Makefiles" \
      -D CMAKE_INSTALL_PREFIX="$PREFIX" \
      -D CMAKE_CXX_FLAGS='-std=c++14' \
      -D NANODBC_ENABLE_UNICODE=OFF \
      -D BUILD_SHARED_LIBS=ON \
      -D NANODBC_DISABLE_LIBCXX=ON \
      -D NANODBC_ODBC_VERSION=SQL_OV_ODBC3 \
      -D NANODBC_DISABLE_EXAMPLES=ON \
      -D NANODBC_DISABLE_TESTS=ON \
      ..

make VERBOSE=1 -j "$n"
make install


