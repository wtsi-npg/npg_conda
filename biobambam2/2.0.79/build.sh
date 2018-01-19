#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-libmaus2="$PREFIX" LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals" LIBS="-lirods_client_api -lrt"
make install prefix="$PREFIX"
