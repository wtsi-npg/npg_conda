#!/bin/sh

set -ex

autoreconf -i

LD_LIBRARY_PATH=$PREFIX/lib ./configure --prefix="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include" \
            LDFLAGS="-L$PREFIX/lib" \
            --with-capnp=$PREFIX \
            --with-boost=$PREFIX

make clean

make install prefix="$PREFIX"
