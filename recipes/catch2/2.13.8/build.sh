#!/bin/sh

set -ex

mkdir -p "$PREFIX/include/catch2"
cp *.hpp "$PREFIX/include/catch2"

