#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd htslib

autoheader
autoconf

./configure \
    --prefix="$PREFIX" \
    --with-libdeflate \
    --enable-libcurl \
    --enable-s3 \
    --enable-gcs \
    --enable-plugins \
    CC="$GCC" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n AR="$AR"
make install prefix="$PREFIX"
popd

