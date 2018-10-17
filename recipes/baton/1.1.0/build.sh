#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" --with-irods="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include/irods" \
            LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"

make -j $n CPPFLAGS="-I$PREFIX/include/irods" \
     LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"
make install prefix="$PREFIX"
