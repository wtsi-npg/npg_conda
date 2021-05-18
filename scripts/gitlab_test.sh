#! /bin/bash
# This script tests newly built dependencies with their dependent
# packages by creating an environment containing (the newly built
# version of) the dependency and any available version of the dependent
# package from prod, then devel, then the local channel.  It is assumed
# that if a version from an earlier channel in that set is successful,
# versions in other channels will also be successful.
#
# Command Line Arguments (pipeline dependent):
#     $1 - CHANNEL_DIR (explicit for global scope)
#     $2 - COMPARE_BRANCH 

. $CONDA_DIR/etc/profile.d/conda.sh

# CONSTANTS
set -e -u -x
IFS=$'\n'

CHANNEL_DIR=$1

prod=$(conda search --quiet -c "$PROD_WSI_CONDA_CHANNEL" --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d' ')
devel=$(conda search --quiet -c "$WSI_CONDA_CHANNEL" --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d' ')
local=$(conda search --quiet -c "file://$CHANNEL_DIR" --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d ' ') 

#FUNCTIONS

cleanup_env() {
    # Removes the testing environment
    
    conda deactivate
    conda remove -y -n "test_env" --all
}

check_package_in_channel() {

    # - Checks whether the dependent package is present in the provided
    #       channel
    # - Creates a test environment containing the newly built package
    # - Installs the dependent package from the provided channel
    # - Finds and runs the conda run_test.* script
    # - Checks for system versions of the libraries that should by provided by
    #   subpackages
    #
    # Args:
    #     $1 - list of packages in a channel (prod, devel or local, defined below)
    #     $2 - conda channel path

    is_root=0
    if [[ "$pkg" =~ "root " ]]
    then
        pkg=$(echo "$pkg" | cut -f 2,3 -d ' ')
        is_root=1
    else
        pkg=$(echo "$pkg" | cut -f 1,2 -d ' ')
    fi

    if [[ "$1" =~  (^|[[:space:]])"$pkg"([[:space:]]|$) ]] || [[ "$(echo $1 | sed 's/\_/\./g')" =~  (^|[[:space:]])"$pkg"([[:space:]]|$) ]]
    then
        IFS=' ' read -r -a pkg <<< "$pkg"
        # install dependency from the local channel and package from
        # selected channel
        (conda create -y -n "test_env" -c file://$CHANNEL_DIR -c $WSI_CONDA_CHANNEL -c pkgs/main --override-channels ${sub[@]} &&
             conda activate "test_env" &&
             conda install -y -c $2 ${pkg[0]}=${pkg[1]} &&
             conda env export &&
             echo "CHECKSUM = $(conda env export | md5sum)")||
            (cleanup_env && echo "installation fail" && return 1)
        # Find and run conda tests -
        #     some packages do not have tests, e.g. irods-runtime
        pkg_dir=$(ls -d -1 $CONDA_DIR/pkgs/${pkg[0]}-${pkg[1]}* | head -n1)
        pkg_test=$(ls $pkg_dir/info/test/run_test.*)
        if [[ -f $pkg_test ]] 
        then
            case "$pkg_test" in
                [*.sh])
                    bash "$pkg_test" || (cleanup_env && echo "test fail" && return 2)
                    ;;
                [*.py])
                    python "$pkg_test" || (cleanup_env && echo "test fail" && return 2)
                    ;;
                [*.pl])
                    perl "$pkg_test" || (cleanup_env && echo "test fail" && return 2)
                    ;;
            esac
        fi

        for subpackage in ${sub[@]}
        do
            for executable in $(ls "$CONDA_DIR/envs/test_env/bin")
            do
                ldd $CONDA_DIR/envs/test_env/bin/$executable | grep $subpackage | grep "/usr/lib/" &&
                    (cleanup_env && echo "system version of ${changed[0]} used" && return 3)
            done
            for library in $(ls "$CONDA_DIR/envs/test_env/lib")
            do
                ldd "$CONDA_DIR/envs/test_env/lib/$library" | grep $subpackage | grep "/usr/lib/" &&
                    (cleanup_env && echo "system version of ${changed[0]} used" && return 3)
            done
        done
        
        cleanup_env
    else
        echo "not in channel"
        if [ $is_root -eq 1 ]
        then
            echo "but is a root package, so may have sub packages"
        else
            return 4
        fi
    fi
    return 0
}

test_previous_root() {

    # called once subpackages of the previous root have been gathered, runs tests

    if [[ -n $root ]]
    then
        if [[ -z $sub ]]
        then
            sub=(${root[0]}=${root[1]})
        fi
        # ensure that the base env is activated
        conda activate
        for pkg in $(tools/bin/recipebook --package ${root[0]} --version ${root[1]} --provides --grouped-packages)
        do
            check_package_in_channel "$prod" "$PROD_WSI_CONDA_CHANNEL" ||
                check_package_in_channel "$devel" "$WSI_CONDA_CHANNEL" ||
                check_package_in_channel "$local" "file://$CHANNEL_DIR"
        done
    fi
}


# LOOP
root=''
sub=''
for changed in $(tools/bin/recipebook --changes origin/$2 --grouped-packages)
do
    IFS=' ' read -r -a changed <<< "$changed"
    if [ ${changed[0]} == "root" ]
    then
        test_previous_root
        root=(${changed[1]} ${changed[2]})
        sub=''
    else
        sub=($sub ${changed[0]}=${changed[1]})
    fi
done

test_previous_root

unset IFS


