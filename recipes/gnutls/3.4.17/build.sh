#!/bin/sh

set -ex

n="$CPU_COUNT"

./configure --prefix="$PREFIX" \
            --with-included-libtasn1 \
            --with-libz-prefix="$PREFIX" \
            --without-idn \
            --without-p11-kit \
            --without-tpm \
            --disable-doc

make -j $n prefix="$PREFIX" CC="$GCC" LD="$LD" \
     CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-Wl,-rpath-link,$PREFIX/lib -Wl,--disable-new-dtags"
make install prefix="$PREFIX"
