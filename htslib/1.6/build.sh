#!/bin/sh

set -e

./configure --prefix="$PREFIX" --enable-libcurl --enable-plugins CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"

cd ./plugins
make install prefix="$PREFIX" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" IRODS_HOME="$PREFIX"
