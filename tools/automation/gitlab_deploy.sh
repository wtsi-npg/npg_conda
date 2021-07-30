#! /bin/bash

set -e -u -x

rsync -rlv --include='*.tar.bz2' --exclude='*' $1/linux-64/ $2/linux-64/ # $BUILD_DIR $CHANNEL_DIR

conda index $2 # $CHANNEL_DIR

aws s3 sync --acl public-read --acl bucket-owner-full-control --exclude '*/.cache/*' $2 $3 # $CHANNEL_DIR $CHANNEL_REM

