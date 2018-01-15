#!/bin/sh

set -e

make 

mkdir -p "$PREFIX/bin"
cp bwa "$PREFIX/bin/"

mkdir -p "$PREFIX/share/man/man1"
cp bwa.1 "$PREFIX/share/man/man1/"
