#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-gnutls --with-nettle --with-io_lib --with-irods=yes CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals" LIBS="-lirods_client_api -lrt"

n=`expr $CPU_COUNT / 4 \| 1`
make install -j $n prefix="$PREFIX"
