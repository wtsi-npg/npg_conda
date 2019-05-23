#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
cp wr "$PREFIX/bin/"

mkdir -p "$PREFIX/etc"
cp wr_config.yml "$PREFIX/etc/"

mkdir -p "$PREFIX/share/doc/wr"
cp README.md "$PREFIX/share/doc/wr/"
