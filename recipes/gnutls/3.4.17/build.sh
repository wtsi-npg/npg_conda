#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" \
            --with-included-libtasn1 \
            --with-included-unistring \
            --with-zlib-prefix="$PREFIX" \
            --without-idn \
            --without-p11-kit \
            --without-tpm
make -j $n
make install prefix="$PREFIX"
