#!/bin/sh

set -ex

n="$CPU_COUNT"

pushd npg_qc_utils

pushd fastq_summ
mkdir -p build
make -j $n CC="$GCC" \
     INCLUDES="-I. -I$PREFIX/include/samtools -I$PREFIX/include" \
     SAMTOOLSLIBPATH="-L$PREFIX/lib" \
     LIBS="-lz -lm"
make install installdir="$PREFIX/bin/"
popd

pushd fastqcheck
mkdir -p build
make -j $n CC="$GCC" \
     INCLUDES="-I. -I$PREFIX/include/samtools -I$PREFIX/include" \
     SAMTOOLSLIBPATH="-L$PREFIX/lib" \
     LIBS="-lz -lm"
make install installdir="$PREFIX/bin/"
popd

pushd norm_fit
mkdir -p build
make -j $n CC="$GCC" \
     INCLUDES="-I.-I$PREFIX/include/samtools -I$PREFIX/include" \
     LIBPATH="-L$PREFIX/lib"
cp ./build/norm_fit "$PREFIX/bin/"
popd

pushd gt_utils
mkdir -p build
make -j $n  CC="$GCC" \
     CPPFLAGS="-I$PREFIX/include" \
     LDFLAGS="-L$PREFIX/lib"
make install installdir="$PREFIX/bin"
popd

popd
