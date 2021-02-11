#! /bin/bash

set -e -u -x

rm -rf $BUILD_DIR
rm -rf $CHANNEL_DIR/..
rm -rf $CONDA_DIR*

if [ -e $CI_PROJECT_DIR/.bashrc.bak ] ; then
    mv $CI_PROJECT_DIR/.bashrc.bak $CI_PROJECT_DIR/.bashrc
fi
