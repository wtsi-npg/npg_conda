#!/bin/sh

set -ex

n="$CPU_COUNT"

export LD_LIBRARY_PATH="$PREFIX/lib"

autoreconf -fi

./configure --prefix="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" \
            LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"

make -j $n
make install prefix="$PREFIX"
