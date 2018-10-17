#!/bin/sh

set -e

function untar_data() {
    if [ -e data.tar.gz ]; then
        tar xz --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.gz
    elif [ -e data.tar.xz ]; then
        tar xJ --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.xz
    fi
}

export TERM=dumb

git submodule init && git submodule update

sudo apt-get install -y g++ g++-4.8 gcc gcc-4.8

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100
sudo update-alternatives --set gcc /usr/bin/gcc-4.8
sudo update-alternatives --set g++ /usr/bin/g++-4.8

sudo apt-get install -y autoconf automake help2man make \
     libtool-bin pkg-config texinfo

sudo apt-get install -y libjson-perl python-dev

sudo apt-get install -y libbz2-dev libcurl4-gnutls-dev \
     libfuse-dev libkrb5-dev libmysqlclient-dev libpam0g-dev \
     libssl-dev unixodbc-dev libxml2-dev zlib1g-dev

./packaging/build.sh --verbose icat postgres
./packaging/build.sh --verbose icommands

cd build

ar vx irods-icommands-4.1.12-64bit.deb
untar_data

ar vx irods-dev-4.1.12-64bit.deb
untar_data

# Fix all the absolute symlinks pointing to /usr/include
perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
