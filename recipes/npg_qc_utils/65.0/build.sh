#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

pushd samtools
./configure --prefix="$PREFIX" --without-curses
make -j $n CFLAGS="-fPIC"
ln -s . include
popd

pushd npg_qc_utils

pushd fastq_summ
mkdir -p build
make -j $n INCLUDES="-I. -I$SRC_DIR/samtools -I$PREFIX/include" SAMTOOLSLIBPATH="-L$SRC_DIR/samtools -L$PREFIX/lib" LIBS="-lz -lm"
make install installdir="$PREFIX/bin/"
popd

pushd fastqcheck
mkdir -p build
make -j $n INCLUDES="-I. -I$SRC_DIR/samtools -I$PREFIX/include" SAMTOOLSLIBPATH="-L$SRC_DIR/samtools -L$PREFIX/lib" LIBS="-lz -lm"
make install installdir="$PREFIX/bin/"
popd

pushd norm_fit
mkdir -p build
make -j $n INCLUDES="-I. -I$PREFIX/include" LIBPATH="-L$PREFIX/lib"
cp ./build/norm_fit "$PREFIX/bin/"
popd

pushd gt_utils
mkdir -p build
make -j $n CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install installdir="$PREFIX/bin"
popd

popd
