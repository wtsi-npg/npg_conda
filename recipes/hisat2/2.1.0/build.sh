#!/bin/sh

set -ex

n="$CPU_COUNT"

make -j $n CC="$GCC" CPP="$CXX" \
     CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

mkdir -p "$PREFIX/bin"

for file in hisat2  hisat2-align-s  hisat2-align-l \
            hisat2-build  hisat2-build-s  hisat2-build-l \
            hisat2-inspect  hisat2-inspect-s  hisat2-inspect-l \
            hisat2_extract_splice_sites.py  hisat2_extract_exons.py
do
    cp $file "$PREFIX/bin"
done
