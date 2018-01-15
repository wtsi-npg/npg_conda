#!/bin/sh

set -e

cd source

make STAR STARlong
make install

mkdir -p "$PREFIX/bin"
cp ../bin/STAR "$PREFIX/bin"
cp ../bin/STARlong "$PREFIX/bin"
