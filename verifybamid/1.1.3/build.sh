#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd libstatgen
make -j $n

cd ../verifybamid
make -j $n
make install INSTALLDIR="$PREFIX/bin" LIB_PATH_GENERAL="../libstatgen"
