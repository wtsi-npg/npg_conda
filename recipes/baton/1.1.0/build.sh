#!/bin/sh

set -ex

n="$CPU_COUNT"

export LD_LIBRARY_PATH="$PREFIX/lib"

CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" \
 LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals" \
 ./configure --prefix="$PREFIX" --with-irods="$PREFIX"

make -j $n \
     CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" \
     LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"
make install prefix="$PREFIX"
