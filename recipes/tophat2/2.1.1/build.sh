#!/bin/sh

set -ex

n=1

# Using --with-boost avoids picking up /usr/lib boost, if present.
./configure --prefix="$PREFIX" \
            --with-boost="$PREFIX" \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n CC="$GCC" \
     INCLUDES="-I. -I$PREFIX/include" LIBPATH="-L$PREFIX/lib" \
     CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix="$PREFIX"
