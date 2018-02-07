#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

for v in $(env | cut -f 1 -d "=" | grep -i perl ); do
    echo "unset $v" && unset $v;
done

./Configure -des -Duseshrplib -Dusethreads -Dprefix="$PREFIX"

make -j $n CFLAGS="-fPIC"
make install
