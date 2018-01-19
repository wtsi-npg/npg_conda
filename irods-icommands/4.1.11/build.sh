#!/bin/sh

set -e

ar vx irods-icommands.deb
tar xz --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.gz

# perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
