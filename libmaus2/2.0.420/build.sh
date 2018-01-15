#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-gnutls --with-nettle --with-io_lib CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" # --with-irods=PATH

n=`expr $CPU_COUNT / 4 \| 1`
make install -j $n prefix="$PREFIX"
