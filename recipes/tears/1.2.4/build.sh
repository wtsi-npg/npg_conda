#!/bin/sh

set -ex

autoreconf -fi

./configure --prefix="$PREFIX" --with-irods="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" \
            LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"

make  CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
