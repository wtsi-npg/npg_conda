#! /bin/bash

set -e -u -x

rsync -av --include='*.tar.bz2' --exclude='*' $BUILD_DIR/linux-64/ $CHANNEL_DIR/linux-64/

conda index $CHANNEL_DIR

aws s3 sync --acl public-read --acl bucket-owner-full-control --exclude '*/.cache/*' $CHANNEL_DIR $CHANNEL_REM
