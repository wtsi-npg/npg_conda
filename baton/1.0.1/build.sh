#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-irods CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
