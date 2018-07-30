#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

pushd htslib
autoreconf
./configure --prefix="$PREFIX" \
            --enable-libcurl \
            --enable-plugins \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make -j $n
make install prefix="$PREFIX"
popd

pushd plugins
make install prefix="$PREFIX" IRODS_HOME="$PREFIX" \
     CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
popd
