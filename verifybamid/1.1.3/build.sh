#!/bin/sh

set -e

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd libstatgen
make

cd ../verifybamid
make install INSTALLDIR="$PREFIX/bin" LIB_PATH_GENERAL="../libstatgen"
