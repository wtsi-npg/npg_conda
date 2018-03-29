#!/bin/sh

set -e

mkdir -p "$PREFIX/lib/java/picard"
cp ./picard-tools-${PKG_VERSION}/*.jar "$PREFIX/lib/java/picard/"
