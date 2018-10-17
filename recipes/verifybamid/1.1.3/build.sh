#!/bin/sh

set -ex

n="$CPU_COUNT"

cd libStatGen
make -j $n CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

cd ../verifybamid
make -j $n CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install INSTALLDIR="$PREFIX/bin" LIB_PATH_GENERAL="../libStatGen"
