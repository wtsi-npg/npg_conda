#!/bin/sh

set -e

ar vx irods-dev.deb
tar xz --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.gz

# Fix all the absolute symlinks pointing to /usr/include
perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
