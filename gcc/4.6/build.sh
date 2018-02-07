#!/bin/sh

set -e

n=$CPU_COUNT

mkdir -p $SRC_DIR/build

cd $SRC_DIR/build
mkdir -p $SRC_DIR/build/gmp
cd $SRC_DIR/build/gmp
../../gmp/configure --disable-shared --enable-static --prefix=$SRC_DIR/build
make -j $n && make install

cd $SRC_DIR/build
mkdir -p $SRC_DIR/build/mpfr
cd $SRC_DIR/build/mpfr
../../mpfr/configure --disable-shared --enable-static --prefix=$SRC_DIR/build --with-gmp=$SRC_DIR/build
make -j $n && make install

cd $SRC_DIR/build
mkdir -p $SRC_DIR/build/mpc
cd $SRC_DIR/build/mpc
../../mpc/configure --disable-shared --enable-static --prefix=$SRC_DIR/build --with-gmp=$SRC_DIR/build --with-mpfr=$SRC_DIR/build
make -j $n && make install

cd $SRC_DIR/build
mkdir -p $SRC_DIR/build/gcc
cd $SRC_DIR/build/gcc
../../gcc/configure --prefix="$PREFIX" --disable-multilib --enable-libgomp --enable-languages=c,c++,fortran --with-gmp=$SRC_DIR/build --with-mpfr=$SRC_DIR/build --with-mpc=$SRC_DIR/build --with-isl=$SRC_DIR/build

make -j $n && make install
