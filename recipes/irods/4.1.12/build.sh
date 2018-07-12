#!/bin/sh

set -e


untar_data() {
    if [ -e data.tar.gz ]; then
        tar xz --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.gz
    elif [ -e data.tar.xz ]; then
        tar xJ --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups < data.tar.xz
    fi
}

unrpm() {
    local rpm="$1"

    mkdir -p ./tmp
    pushd tmp
    rpm2cpio ../"$rpm" | cpio --extract --make-directories
    popd

    tar cf - -C ./tmp . | tar xv --strip-components=2 --directory="$PREFIX" --exclude='*.o' --exclude-backups
    rm -r ./tmp
}

git submodule init && git submodule update

export CCFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export TERM=dumb

./packaging/build.sh --verbose icat postgres
./packaging/build.sh --verbose icommands

cd build

# Ubuntu
if [ -f irods-icommands-4.1.12-64bit.deb ]; then
    ar vx irods-icommands-4.1.12-64bit.deb
    untar_data
fi

if [ -f irods-dev-4.1.12-64bit.deb ] ; then
    ar vx irods-dev-4.1.12-64bit.deb
    untar_data
fi

# RHEL
if [ -f irods-icommands-4.1.12-64bit-centos5.rpm ] ; then
    unrpm irods-icommands-4.1.12-64bit-centos5.rpm
fi

if [ -f irods-dev-4.1.12-64bit-centos5.rpm ] ; then
    unrpm irods-dev-4.1.12-64bit-centos5.rpm
fi

# Fix all the absolute symlinks pointing to /usr/include
perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
