#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
cp ./bin/* "$PREFIX/bin/"

mkdir -p "$PREFIX/lib"
cp ./lib/* "$PREFIX/lib/"
