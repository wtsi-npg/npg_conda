#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" --with-apr="$PREFIX" --with-apr-util="$PREFIX" \
            --enable-authn_core --enable-authz_host --enable-authz_user \
            --enable-authz_core --enable-headers --enable-setenvif \
            --enable-rewrite --enable-so --enable-alias --enable-dir \
            --enable-mime --enable-log_config --enable-env --enable-ssl \
            --enable-proxy --enable-proxy_html --enable-xml2enc \
            --disable-userdir --disable-info --disable-status \
            --disable-include --disable-ldap --disable-authnz_ldap \
            CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

make -j $n
make install prefix="$PREFIX"
