#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd src

autoreconf -i
./configure --prefix="$PREFIX" \
	    --host=${HOST} \
            --build=${BUILD} \
	    --with-crypto-impl=openssl \
	    --without-tcl \
            --without-libedit \
            --without-readline \
            --without-system-verto

make -j $n
make install

popd
