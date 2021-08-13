
set -e

if [ -z "$TEST_TMPDIR" ]; then
    export TEST_TMPDIR="$(mktemp -d "${BATS_TMPDIR}/npg_conda.XXXXXX")"
fi

setup() {
    for environ in staging live; do
        for role in prod test; do
            base="$TEST_TMPDIR/channels"
            mkdir -p "$base/$environ/$role/RedHat/7.5/linux-64"
            mkdir -p "$base/$environ/$role/Ubuntu/18.04/linux-64"
        done
    done

    for role in prod test; do
        # RedHat live; foo
        cp "$BATS_TEST_DIRNAME/data/building/packages/foo-1.0.0-0.tar.bz2" \
           "$TEST_TMPDIR/channels/live/$role/RedHat/7.5/linux-64"

        # Ubuntu live; foo, bar
        cp "$BATS_TEST_DIRNAME/data/building/packages/foo-1.0.0-0.tar.bz2" \
           "$TEST_TMPDIR/channels/live/$role/Ubuntu/18.04/linux-64"
        cp "$BATS_TEST_DIRNAME/data/building/packages/bar-1.0.0-0.tar.bz2" \
           "$TEST_TMPDIR/channels/live/$role/Ubuntu/18.04/linux-64"

        # Ubuntu staging; baz
        cp "$BATS_TEST_DIRNAME/data/building/packages/baz-1.0.0-0.tar.bz2" \
           "$TEST_TMPDIR/channels/staging/$role/Ubuntu/18.04/linux-64"
    done
}

teardown() {
    rm -r "$TEST_TMPDIR"
}
