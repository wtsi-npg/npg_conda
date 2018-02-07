#!/bin/sh

set -e

git submodule update --init --recursive

make EIGEN=noinstall HDF5=noinstall HTS=noinstall CXXFLAGS="-I$PREFIX/include -I$PREFIX/include/eigen3" LDFLAGS="-L$PREFIX/lib"

# There is no install target in the Makefile
mkdir -p "$PREFIX/bin"

cp nanopolish "$PREFIX/bin/"
