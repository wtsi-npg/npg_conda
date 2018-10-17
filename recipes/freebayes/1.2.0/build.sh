#!/bin/sh

set -ex

make -j 1 CC="$GCC" CXX="$CXX" \
     CXXFLAGS="-I$PREFIX/include" \
     CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"
cp bin/freebayes bin/bamleftalign "$PREFIX/bin/"
