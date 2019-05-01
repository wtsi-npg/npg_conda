#!/bin/bash

set -eo pipefail

shopt -s nullglob

trap cleanup EXIT INT TERM

cleanup() {
    if [ -d "$TMP_CHANNEL" ]; then
        rm -r "$TMP_CHANNEL"
    fi
}

log_error() {
    local msg="$1"
    echo -e "$(print_iso8601_time)\tERROR\t$msg"
}

log_notice() {
    local msg="$1"
    echo -e "$(print_iso8601_time)\tNOTICE\t$msg"
}

print_iso8601_time() {
    awk 'BEGIN { print strftime("%FT%T%z", systime()) }'
}

usage() {
    cat 1>&2 << EOF

This script updates S3 Conda channels with any new packages that have
been placed in a local staging directory hierarchy. If any changes are
made to the remote channel, a copy of the previous state is preserved
on the local filesystem.

The local directory hierarchy must be organised according to the
following conventions into roles ("prod", for production and "test",
for testing), Linux distributions ("Ubuntu", "RedHat"), releases
(e.g. "12.04", "16.04", "18.04" for Ubuntu, "7.5" for RedHat
Enterprise), and Conda software architecture (currently only
"linux-64"):

Current state of deployed channels:

<LOCAL ROOT>/live/prod/RedHat/7.5/linux-64/
<LOCAL ROOT>/live/prod/Ubuntu/12.04/linux-64/
<LOCAL ROOT>/live/prod/Ubuntu/18.04/linux-64/

<LOCAL ROOT>/live/test/RedHat/7.5/linux-64/
<LOCAL ROOT>/live/test/Ubuntu/12.04/linux-64/
<LOCAL ROOT>/live/test/Ubuntu/18.04/linux-64/

New packages to be deployed:

<LOCAL ROOT>/staging/test/Ubuntu/18.04/linux-64/*
<LOCAL ROOT>/staging/prod/Ubuntu/18.04/linux-64/*

Previous state of deployed channels:

<LOCAL ROOT>/archive/


New packages should be added to the appropriate directories under
"staging" and this script run with the -r CLI option set to <LOCAL
ROOT>. This script will locate the new packages, move them into a copy
of the appropriate channel, index that channel and then synchronize it
to the S3 bucket and prefix. If that process is successful, the old
state of the channel under the "live" directory will be moved to a
timestamped directory in the "archive" directory and the new copy of
the channel will be moved to "live" to replace it.

As this script will move file from staging, they must be given
suitable write permissions for the user running this script.


Usage: $0 -b <S3 bucket> -p <S3 prefix> -r <local root directory>
   [-h] [-t <num threads>] [-v] [-y]

Options:

 -b An existing S3 bucket name (without any s3:// prefix). Required.

 -h  Print usage and exit.

 -p An S3 prefix within the bucket. Required.

 -r A local root directory containing Conda channels to be updated.
    Required.

 -t The number of threads to use when indexing the channeld. Optional,
    defaults to 8.

 -v  Print verbose messages.

 -y Synchronise with S3 in dry-run mode (do nothing). Optional.

EOF
}


S3CMD=s3cmd
S3_BUCKET=
S3_PREFIX=
S3_SYNC_ARGS=("--acl-public")

NUM_THREADS=8
LOCAL_ROOT=

while getopts "b:hp:r:t:vy" option; do
    case "$option" in
        b)
            S3_BUCKET="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        p)
            S3_PREFIX="$OPTARG"
            ;;
        r)
            LOCAL_ROOT="$OPTARG"
            ;;
        t)
            NUM_THREADS="$OPTARG"
            ;;
        v)
            set -x
            ;;
        y)
            S3_SYNC_ARGS+=("--dry-run")
            ;;
        *)
            usage
            echo "Invalid argument!"
            exit 4
            ;;
    esac
done

if [ -z "$S3_BUCKET" ] ; then
    usage
    echo -e "\nERROR:\n  A -b <S3 bucket> argument is required"
    exit 4
fi

if [ -z "$S3_PREFIX" ] ; then
    usage
    echo -e "\nERROR:\n  A -p <S3 prefix> argument is required"
    exit 4
fi

if [ -z "$LOCAL_ROOT" ] ; then
    usage
    echo -e "\nERROR:\n  A -r <local root> argument is required"
    exit 4
fi

if [ ! -d "$LOCAL_ROOT" ]; then
    usage
    echo -e "\nERROR:\n  The local root directory '$LOCAL_ROOT' does not exist"
    exit 4
fi

if [ "$NUM_THREADS" -ne "$NUM_THREADS" ]; then
    usage
    echo -e "\nERROR:\n  The -t <num threads> value must be an integer"
    exit 4
fi

ARCHIVE_ROOT="$LOCAL_ROOT/archive"
LIVE_ROOT="$LOCAL_ROOT/live"
STAGING_ROOT="$LOCAL_ROOT/staging"

CONDA_INDEX_ARGS=("--no-progress" "--threads" "$NUM_THREADS")
TMP_CHANNEL=$(mktemp -d ${TMPDIR:-/tmp/}$(basename -- "$0").XXXXXXXXXX)

ROLES=("test" "prod")

NUM_ERRORS=0

for role in "${ROLES[@]}"; do
    log_notice "Working on $role ..."
    distro_dirs=("$LIVE_ROOT/$role"/*)

    for distro_dir in "${distro_dirs[@]}"; do
        distro=$(basename "$distro_dir")
        log_notice "Working on $distro ..."

        release_dirs=("$distro_dir"/*)
        for release_dir in "${release_dirs[@]}"; do
            release=$(basename "$release_dir")
            log_notice "Working on $release ..."

            now=$(print_iso8601_time)
            release_dir="$LIVE_ROOT/$role/$distro/$release"
            staging_dir="$STAGING_ROOT/$role/$distro/$release"
            archive_dir="$ARCHIVE_ROOT/$role/$distro/$release/$now"

            # Find packages staged for addition to the channels
            pkgs=("$staging_dir"/*/*.tar.bz2)
            num_pkgs="${#pkgs[@]}"
            if [ "$num_pkgs" -gt 0 ]; then
                log_notice "Found $num_pkgs new packages staged in $staging_dir"

                # Create a temporary directory containing a copy of
                # the current channel contents
                tmp_dir=$(mktemp -d ${TMPDIR:-/tmp/}$(basename -- "$0").XXXXXXXXXX)
                upload_dir="$tmp_dir/$role/$distro/$release"
                mkdir -p "$upload_dir"
                cp -r --no-target-directory "$release_dir" "$upload_dir"

                # Move staged packages to the temporary directory
                for pkg in "${pkgs[@]}"; do
                    if [ ! -w "$pkg" ]; then
                        user=$(id -u -n)
                        log_error "$pkg is not writable by $user, skipping it"
                        (( NUM_ERRORS++ ))
                    fi
                    
                    architecture_dir=$(basename $(dirname "$pkg"))
                    mkdir -p "$upload_dir/$architecture_dir"
                    mv "$pkg" "$upload_dir/$architecture_dir"
                done

                # Index the temporary directory as a Conda channel and
                # upload to S3
                log_notice "Indexing $upload_dir"
                conda index ${CONDA_INDEX_ARGS[@]} "$upload_dir"

                s3_url="s3://$S3_BUCKET/$S3_PREFIX/$role/$distro/$release/"
                log_notice "Syncing to $s3_url"
                $S3CMD sync ${S3_SYNC_ARGS[@]} "$upload_dir/" "$s3_url"

                # Create a timestamped directory to contain the old
                # channel contents and move the old channel to it
                mkdir -p "$archive_dir"
                log_notice "Moving $release_dir to $archive_dir"
                mv --no-target-directory "$release_dir" "$archive_dir"

                # Replace the old channel directory with the new one
                log_notice "Updating $release_dir"
                mv "$upload_dir" "$release_dir"

                rm -r "$tmp_dir"
            else
                log_notice "No new packages were staged in $staging_dir"
            fi
        done
    done
done

cleanup

if [ "$NUM_ERRORS" -gt 0 ]; then
    exit 5
fi
