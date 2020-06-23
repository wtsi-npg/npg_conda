#!/bin/sh

set -ex

n="$CPU_COUNT"

autoreconf -i

LD_LIBRARY_PATH=$PREFIX/lib ./configure --prefix="$PREFIX" \
            CFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" \
            CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" \
            LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"

make -j $n
make install prefix="$PREFIX"
