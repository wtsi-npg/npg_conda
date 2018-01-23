#!/bin/sh

set -e

./configure --prefix="$PREFIX"

make -j 3
make install

PATH="$PREFIX/bin:$PATH" npm install -g npm@4.5.0
PATH="$PREFIX/bin:$PATH" npm install -g bower@1.8.2 \
                                        grunt-cli@1.2.0 \
                                        node-qunit-phantomjs@1.4.0 \
                                        yarn@1.3.2
