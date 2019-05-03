#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd htslib

cp aclocal.m4 aclocal.m4.tmp
autoreconf
cp aclocal.m4.tmp aclocal.m4

./configure \
    --prefix="$PREFIX" \
    --enable-libcurl \
    --enable-plugins \
    CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n AR="$AR"
make install prefix="$PREFIX"
popd

pushd plugins
make IRODS_HOME="$PREFIX" \
     CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
popd
