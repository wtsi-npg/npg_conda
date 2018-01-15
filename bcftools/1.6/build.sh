#!/bin/sh

set -e

./configure --prefix="$PREFIX" --with-htslib="$PREFIX"
make # Workaround https://github.com/samtools/bcftools/issues/727
make install prefix="$PREFIX"
