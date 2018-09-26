#!/bin/bash

TEST_PATH=$(readlink -f $BASH_SOURCE)
TEST_DIR=$(dirname $TEST_PATH)

SCRIPT_DIR=$(readlink -f $TEST_DIR/../scripts)
export PATH=$TEST_DIR:$SCRIPT_DIR:$PATH

bats $TEST_DIR/*.bats
