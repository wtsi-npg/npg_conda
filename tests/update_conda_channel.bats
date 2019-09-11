#!usr/bin/env bats

load test_helper

@test "Packages are moved from staging" {
    # baz package is in staging
    for role in prod test; do
        [ -f "$TEST_TMPDIR/channels/staging/$role/Ubuntu/18.04/linux-64/baz-1.0.0-0.tar.bz2" ]
    done
    
    run update_conda_channel.sh -b "$TEST_TMPDIR/s3_bucket" \
        -p "s3_prefix" \
        -r "$TEST_TMPDIR/channels"
    [ "$status" -eq 0 ]

    # baz package was moved from staging
    for role in prod test; do
        [ ! -f "$TEST_TMPDIR/channels/staging/$role/Ubuntu/18.04/linux-64/baz-1.0.0-0.tar.bz2" ]
    done
}


@test "Packages are added to S3 channel" {
    # baz package is not in the mock S3 bucket
    for role in prod test; do
        [ ! -e "$TEST_TMPDIR/s3_bucket/s3_prefix/$role/Ubuntu/18.04/linux-64/baz-1.0.0-0.tar.bz2" ]
    done

    run update_conda_channel.sh -b "$TEST_TMPDIR/s3_bucket" \
        -p "s3_prefix" \
        -r "$TEST_TMPDIR/channels"
    [ "$status" -eq 0 ]

    # baz package is in the mock S3 bucket
    for role in prod test; do
        [ -f "$TEST_TMPDIR/s3_bucket/s3_prefix/$role/Ubuntu/18.04/linux-64/baz-1.0.0-0.tar.bz2" ]
        [ -f "$TEST_TMPDIR/s3_bucket/s3_prefix/$role/Ubuntu/18.04/linux-64/repodata.json" ]
    done
}

@test "Channel is added to archive" {

    run update_conda_channel.sh -b "$TEST_TMPDIR/s3_bucket" \
        -p "s3_prefix" \
        -r "$TEST_TMPDIR/channels"
    [ "$status" -eq 0 ]

    nullglob_off=
    shopt -u | grep -q nullglob && nullglob_off=1
    shopt -s nullglob

    for role in prod test; do
        foo=("$TEST_TMPDIR"/channels/archive/$role/Ubuntu/18.04/*/linux-64/foo*)
        [ "${#foo[@]}" -eq 1 ]

        bar=("$TEST_TMPDIR"/channels/archive/$role/Ubuntu/18.04/*/linux-64/bar*)
        [ "${#bar[@]}" -eq 1 ]

        baz=("$TEST_TMPDIR"/channels/archive/$role/Ubuntu/18.04/*/linux-64/baz*)
        [ "${#baz[@]}" -eq 0 ]
    done

    if [ "$nullglob_off" ]; then
        shopt -u nullglob
    fi
}
