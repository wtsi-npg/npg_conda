#! /bin/bash
# This script tests newly built dependencies with their dependent
# packages by creating an environment containing (the newly built
# version of) the dependency and any available version of the dependent
# package from prod, then devel, then the local channel.  It is assumed
# that if a version from an earlier channel in that set is successful,
# versions in other channels will also be successful.
#
# Command Line Arguments (pipeline dependent):
#     $1 - CHANNEL_DIR 
#     $2 - COMPARE_BRANCH 



# CONSTANTS
set -e -u -x
IFS=$'\n'

prod=$(conda search --quiet -c "$PROD_WSI_CONDA_CHANNEL" --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d' ')
devel=$(conda search --quiet -c "$WSI_CONDA_CHANNEL" --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d' ')
local=$(conda search --quiet -c "file://$1" --override-channels | sed -E 's/[[:space:]]+/ /g' | cut -f 1,2 -d ' ') 



#FUNCTIONS

cleanup_env() {
    # Removes the testing environment
    
    conda deactivate
    conda remove -n "test_env" --all
}

check_package_in_channel() {

    # - Checks whether the dependent package is present in the provided
    #       channel
    # - Creates a test environment containing the newly built package
    # - Installs the dependent package from the provided channel
    # - Finds and runs the conda run_test.* script
    #
    # Args:
    #     $1 - list of packages in a channel (prod, devel or local, defined below)
    #     $2 - conda channel path
    
    if [[ "$1" =~  (^|[[:space:]])"$pkg"([[:space:]]|$) ]]
    then
        IFS=' ' pkg=($pkg)
        # install dependency from the local channel and package from
        # selected channel
        (conda create -y -n "test_env" -c file://$CHANNEL_DIR \
               ${changed[0]}==${changed[1]} &&
             conda activate "test_env" &&
             conda install -c $2 ${pkg[0]}=${pkg[1]} &&
             conda env export &&
             echo "CHECKSUM = $(conda env export | md5sum)")||
            (cleanup_env && echo "installation fail" && return 1)
        # Find and run conda tests -
        #     some packages do not have tests, e.g. irods-runtime
        if [[ -f $CONDA_DIR/pkgs/${pkg[0]}-${pkg[1]}*/info/test/run_test.* ]] 
        then
            test=$(ls $CONDA_DIR/pkgs/${pkg[0]}-${pkg[1]}*/info/test/run_test.*)
            case "$test" in
                [*.sh])
                    bash "$test" || (cleanup_env && echo "test fail" && return 2)
                    ;;
                [*.py])
                    python "$test" || (cleanup_env && echo "test fail" && return 2)
                    ;;
                [*.pl])
                    perl "$test" || (cleanup_env && echo "test fail" && return 2)
                    ;;
            esac
        fi

        ldd "$CONDA_DIR/envs/test_env/bin/*" | grep ${changed[0]} | grep "/usr/lib/" &&
            (cleanup_env && echo "system version of ${changed[0]} used" && return 3)
        
        ldd "$CONDA_DIR/envs/test_env/lib/*" | grep ${changed[0]} | grep "/usr/lib/" &&
            (cleanup_env && echo "system version of ${changed[0]} used" && return 3)

        cleanup_env
    else
        echo "not in channel"
        return 4
    fi
    return 0
}



# LOOP

for changed in $(tools/bin/recipebook --changes origin/$2 --sub-package)
do
    IFS=' ' changed=($changed)
    for pkg in $(tools/bin/recipebook --package ${changed[0]} --version ${changed[1]} --provides --sub-package)
    do
        check_package_in_channel "$prod" "$PROD_WSI_CONDA_CHANNEL" ||
            check_package_in_channel "$devel" "$WSI_CONDA_CHANNEL" ||
            check_package_in_channel "$local" "file://$1"
    done
done

unset IFS


