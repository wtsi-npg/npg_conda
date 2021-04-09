#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" \
	    --without-iconv \
	    --without-lz4 \
	    --without-lzo2 \
	    --without-zstd \
	    --without-cng \
	    --without-openssl \
	    --without-nettle \
	    --without-expat

make -j $n
make install
