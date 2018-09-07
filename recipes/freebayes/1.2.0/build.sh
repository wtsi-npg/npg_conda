#!/bin/sh

set -e

export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPPFLAGS="-I$PREFIX/include"

make -j 1
cp bin/freebayes bin/bamleftalign $PREFIX/
