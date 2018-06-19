#!/bin/sh

set -e

n=$CPU_COUNT

for pkg in gmp mpfr mpc isl gcc; do
    mkdir -p "$SRC_DIR/$pkg-build"
done

pushd gmp-src
./configure --disable-shared --enable-static \
            --prefix="$SRC_DIR/gmp-build" \
            CFLAGS="-O2 -pedantic -fomit-frame-pointer -m64 -march=x86-64" \
            MPN_PATH="x86_64 generic"

make -j $n && make check && make install
popd

pushd mpfr-src
./configure --disable-shared --enable-static \
            --prefix="$SRC_DIR/mpfr-build" \
            --with-gmp="$SRC_DIR/gmp-build"

make -j $n && make check && make install
popd

pushd mpc-src
./configure --disable-shared --enable-static \
            --prefix="$SRC_DIR/mpc-build" \
            --with-gmp="$SRC_DIR/gmp-build" \
            --with-mpfr="$SRC_DIR/mpfr-build"

make -j $n && make check && make install
popd

pushd isl-src
./configure --disable-shared --enable-static \
            --prefix="$SRC_DIR/isl-build" \
            --with-gmp-prefix="$SRC_DIR/gmp-build"

make -j $n && make install
popd

pushd gcc-src
./configure --prefix="$PREFIX" \
            --enable-checking=release \
            --with-arch=x86-64 \
            --disable-multilib \
            --enable-libgomp \
            --enable-languages=c,c++,fortran \
            --with-gmp="$SRC_DIR/gmp-build" \
            --with-mpfr="$SRC_DIR/mpfr-build" \
            --with-mpc="$SRC_DIR/mpc-build" \
            --with-isl="$SRC_DIR/isl-build"

make -j $n && make install
popd
