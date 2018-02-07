#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" --with-libmaus2="$PREFIX" LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals" LIBS="-lirods_client_api -lrt"

make -j $n
make install prefix="$PREFIX"
