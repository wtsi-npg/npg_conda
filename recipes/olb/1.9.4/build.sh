#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

export CC="$PREFIX/bin/gcc"
export CXX="$PREFIX/bin/g++"
export LIB="$PREFIX/lib"

export PATH="$SRC_DIR/opt/bin:$PATH"
export CPPFLAGS="-I$SRC_DIR/opt/include -I$PREFIX/include"
export LDFLAGS="-L$SRC_DIR/opt/lib -L$PREFIX/lib"

# We do not use the top level Makefile here because it introduces a
# test for Perl XML::Simple, a module that is not required for
# building. In addition, its compilation test for libfft fails under a
# Conda build environment.

mkdir -p build
cd build
cmake -DHAVE_FFTW3F=ON \
      -DFFTW3F_INCLUDE_DIR="$PREFIX/include" \
      -DFFTW3F_LIBRARY="$PREFIX/lib/libfftw3f.a" \
      -DCMAKE_CXX_FLAGS="-fpermissive" ..

make -j $n

make install
mkdir -p "$PREFIX/bin"
cp -R "$SRC_DIR/bin"* "$PREFIX"
