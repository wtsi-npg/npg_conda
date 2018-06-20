#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

make -j $n prefix="$PREFIX"

mkdir -p "$PREFIX/include"
cp --preserve=links -R "$SRC_DIR/include/serial" "$PREFIX/include/"
cp --preserve=links -R "$SRC_DIR/include/tbb" "$PREFIX/include/"

mkdir -p "$PREFIX/lib"
cp  --preserve=links $SRC_DIR/build/*release/*.so* "$PREFIX/lib/"
