#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" --with-irods="$PREFIX" CPPFLAGS="-I$PREFIX/include/irods" LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"

make -j $n
make install prefix="$PREFIX"
