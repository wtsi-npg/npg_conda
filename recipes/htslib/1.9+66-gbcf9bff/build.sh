#!/bin/sh

set -ex

n=`expr $CPU_COUNT / 4 \| 1`

pushd htslib

cp aclocal.m4 aclocal.m4.tmp
autoreconf
cp aclocal.m4.tmp aclocal.m4

CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" \
        ./configure --prefix="$PREFIX" \
        --enable-libcurl \
        --enable-libdeflate \
        --enable-plugins \

make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
popd

pushd plugins
make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" \
     IRODS_HOME="$PREFIX"
make install prefix="$PREFIX"
popd
