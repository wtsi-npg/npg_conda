#!/bin/sh

set -e

export PERL5LIB="$PREFIX/lib/perl5"
eval $(perl -Mlocal::lib="$PREFIX")

env

export PERL_CPANM_HOME="$SRC_DIR/cpanm_home"
export PERL_MM_USE_DEFAULT=1 

pushd "$PREFIX/bin"
ln -s $(basename "$AR")  ar
ln -s $(basename "$GCC") cc
ln -s $(basename "$LD")  ld
popd

perl Build.PL
# Conda's long shebang line gets truncated, so replace it
# sed -i.orig -e '1 s/^.*$/#!\/usr\/bin\/env perl/' Build

cpanm --force ExtUtils::Helpers
cpanm --force Test::Cmd

cpanm --installdeps .
./Build install
