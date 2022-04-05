#!/bin/sh

set -e

mkdir -p "$PREFIX/bin"
cp filebeat "$PREFIX/bin/"

mkdir -p "$PREFIX/etc"
cp -r module "$PREFIX/etc/"
cp -r modules.d "$PREFIX/etc/"
cp filebeat.yml "$PREFIX/etc/"

mkdir -p "$PREFIX/share/doc/filebeat"
cp README.md "$PREFIX/share/doc/filebeat/"
