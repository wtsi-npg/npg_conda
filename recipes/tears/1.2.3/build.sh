#!/bin/sh

set -e

autoreconf -fi

./configure --prefix="$PREFIX" --with-irods="$PREFIX" CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals"

make
make install prefix="$PREFIX"
