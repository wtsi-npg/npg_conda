#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-irods="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
