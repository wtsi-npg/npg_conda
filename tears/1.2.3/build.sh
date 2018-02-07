#!/bin/sh

set -e

autoreconf -fi

./configure --prefix="$PREFIX" --with-irods CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make
make install prefix="$PREFIX"
