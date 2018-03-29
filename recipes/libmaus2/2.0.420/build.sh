#!/bin/sh

set -e

n=$CPU_COUNT

./configure --prefix="$PREFIX" --with-gnutls --with-nettle --with-io_lib --with-irods=yes CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals" LIBS="-lirods_client_api -lrt"

make -j $n
make install prefix="$PREFIX"
