#!/bin/sh

set -ex

autoreconf -fi

export LD_LIBRARY_PATH="$PREFIX/lib"

CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/irods" \
 LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals" \
              ./configure --prefix="$PREFIX" --with-irods="$PREFIX"

make  CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
