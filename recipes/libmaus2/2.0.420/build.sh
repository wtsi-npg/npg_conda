#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" \
            --with-gnutls \
            --with-nettle \
            --with-io_lib \
            --with-irods=yes \
            CPPFLAGS="-I$PREFIX/include" \
            LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib/irods/externals" \
            LIBS="-lirods_client_api -lrt"

make -j $n CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib -L$PREFIX/lib/irods/externals"
make install prefix="$PREFIX"
