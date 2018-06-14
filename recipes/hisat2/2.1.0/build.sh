#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

make -j $n

mkdir -p "$PREFIX/bin"

for file in hisat2  hisat2-align-s  hisat2-align-l \
            hisat2-build  hisat2-build-s  hisat2-build-l \
            hisat2-inspect  hisat2-inspect-s  hisat2-inspect-l \
            hisat2_extract_splice_sites.py  hisat2_extract_exons.py
do
    cp $file "$PREFIX/bin"
done