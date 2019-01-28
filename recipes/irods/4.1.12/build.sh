#!/bin/sh

set -ex

untar_data() {
    if [ -e data.tar.gz ]; then
        tar xz --strip-components=2 --directory="$PREFIX" \
            --exclude='*.o' --exclude-backups < data.tar.gz
    elif [ -e data.tar.xz ]; then
        tar xJ --strip-components=2 --directory="$PREFIX" \
            --exclude='*.o' --exclude-backups < data.tar.xz
    fi
}

unrpm_data() {
    local rpm="$1"
    mkdir -p ./tmp
    pushd tmp
    rpm2cpio ../"$rpm" | cpio --extract --make-directories
    popd
    tar cf - -C ./tmp . | tar xv --strip-components=2 --directory="$PREFIX" \
                              --exclude='*.o' --exclude-backups
    rm -r ./tmp
}

install_gcc_ubuntu() {
    GCC_VERSION=
    grep precise /etc/lsb-release && GCC_VERSION="4.6"
    grep xenial  /etc/lsb-release && GCC_VERSION="4.8"
    grep bionic  /etc/lsb-release && GCC_VERSION="4.8"

    sudo apt-get install -y "g++-$GCC_VERSION" "gcc-$GCC_VERSION"

    sudo update-alternatives --install /usr/bin/gcc gcc "/usr/bin/gcc-$GCC_VERSION" 100
    sudo update-alternatives --install /usr/bin/g++ g++ "/usr/bin/g++-$GCC_VERSION" 100
    sudo update-alternatives --set gcc "/usr/bin/gcc-$GCC_VERSION"
    sudo update-alternatives --set g++ "/usr/bin/g++-$GCC_VERSION"
}

install_deps_ubuntu() {
    sudo apt-get install -y autoconf automake help2man make \
         libtool pkg-config texinfo

    sudo apt-get install -y libjson-perl python-dev

    sudo apt-get install -y libbz2-dev libcurl4-gnutls-dev \
         libfuse-dev libkrb5-dev libmysqlclient-dev libpam0g-dev \
         libssl-dev unixodbc-dev libxml2-dev zlib1g-dev
}

# Requires:
#
# sudo subscription-manager register --org="..." --activationkey="..."
# sudo subscription-manager repos --enable rhel-7-server-extras-rpms
# sudo subscription-manager repos --enable rhel-7-server-supplementary-rpms
# sudo subscription-manager repos --enable rhel-7-server-optional-rpms

install_gcc_rhel() {
    sudo yum install -y gcc-c++
}

install_deps_rhel() {
    sudo yum install -y help2man make rpm-build

    sudo yum install -y perl-JSON python-devel

    sudo yum install -y bzip2-devel curl-devel \
         fuse-devel krb5-devel pam-devel \
         openssl-devel unixODBC-devel libxml2-devel zlib-devel
}

export TERM=dumb

git submodule init && git submodule update

if [ -f /etc/lsb-release ]; then
    install_gcc_ubuntu
    install_deps_ubuntu

    ./packaging/build.sh --verbose icat postgres
    ./packaging/build.sh --verbose icommands

    cd build

    ar vx irods-icommands-4.1.12-64bit.deb
    untar_data

    ar vx irods-dev-4.1.12-64bit.deb
    untar_data
fi

if [ -f /etc/redhat-release ]; then
    install_gcc_rhel
    install_deps_rhel

    ./packaging/build.sh --verbose icat postgres
    ./packaging/build.sh --verbose icommands

    cd build

    unrpm_data irods-icommands-4.1.12-64bit-centos[0-9].rpm
    unrpm_data irods-dev-4.1.12-64bit-centos[0-9].rpm
fi

# Fix all the absolute symlinks pointing to /usr/include
perl -le 'use strict; use File::Basename; foreach (@ARGV) { if (my $f = readlink $_) { if ($f =~ m{^/usr/}sm) { unlink $_; symlink(basename($f), $_) } } }' $PREFIX/include/irods/*.hpp
