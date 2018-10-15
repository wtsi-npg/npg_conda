#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

pushd htslib

cp aclocal.m4 aclocal.m4.tmp
autoreconf
cp aclocal.m4.tmp aclocal.m4

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
