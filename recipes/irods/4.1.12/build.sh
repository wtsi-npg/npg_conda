#!/bin/sh

set -e

git submodule init && git submodule update

export CCFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export TERM=dumb

./packaging/build.sh --verbose icat postgres
./packaging/build.sh --verbose icommands

cd build

ar vx irods-icommands-4.1.12-64bit.deb
tar xJ --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.xz

ar vx irods-dev-4.1.12-64bit.deb
tar xJ --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.xz

# Fix all the absolute symlinks pointing to /usr/include
perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
