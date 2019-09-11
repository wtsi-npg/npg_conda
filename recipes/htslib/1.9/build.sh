#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd htslib

cp aclocal.m4 aclocal.m4.tmp || echo no aclocal.m4
autoreconf
cp aclocal.m4.tmp aclocal.m4 || true

./configure \
    --prefix="$PREFIX" \
    --prefix="$PREFIX" \
    --enable-libcurl \
    --enable-s3 \
    --enable-gcp \
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
