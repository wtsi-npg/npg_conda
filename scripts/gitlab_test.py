#! /usr/bin/env python3

import argparse
import os
import sys
from channel import Channel, install_from_channels
from package import Package, LibError
from conda.cli.python_api import run_command, Commands
from conda.exceptions import PackagesNotFoundError
import hashlib
import glob
lib = os.path.realpath(os.path.join(os.path.dirname(__file__),
                                    "..", "tools", "recipebook"))
if lib not in sys.path:
    sys.path.insert(0, lib)

from recipebook import RecipeBook, find_recipe_files, find_changed_recipe_files

parser = argparse.ArgumentParser(
    description="A script to run tests on the dependencies of newly built "
    "packages to ensure compatibility"
)

parser.add_argument("-b", "--build_dir",
                    help="The directory to which the packages have been built")
parser.add_argument("-c", "--changes",
                    help="The branch against which recipebook will compare")
parser.add_argument("-p", "--prod_channel",
                    help="Address of the prod channel")
parser.add_argument("-d", "--devel_channel",
                    help="Address of the devel channel")

args = parser.parse_args()

prod = Channel(args.prod_channel)
devel = Channel(args.devel_channel)
local = Channel(args.build_dir)
defaults = Channel("pkgs/main")


def install_package_products(package: Package, primary_channel: Channel,
                             env: str = ""):
    """Finds the names of the output packages from the recipe for package,
    and installs them in the specified environment

    Args:
        package: The name of the package recipe
        primary_channel: The channel that should be highest priority
        env: The environment to install into, defaults to current channel

    """
    if package.sub_packages():
        for sub in package.sub_packages():
            if primary_channel.has_package((sub, package.version())):
                install_from_channels(channels=[primary_channel, devel, defaults],
                                      package=sub + "=" + package.version(),
                                      env=env, override=True)
    else:
        if primary_channel.has_package(package.nv()):
            install_from_channels(channels=[primary_channel, devel, defaults],
                                  package="=".join(package.nv()),
                                  env=env, override=True)


def test_descendant(changed_package: Package, descendant_package: Package,
                    channel: Channel, env: str):
    """Run tests on the version of a dependant package that is in the provided
     channel when installed with the new build of the changed package

    Args:
        changed_package: The newly built package
        descendant_package: A package that depends on changed_package
        channel: The channel from which to install descendant_package
        env: The environment name that should be used for the test
    """
    run_command(Commands.CREATE, "-n", env)
    try:
        install_package_products(changed_package, local, env)
    except PackagesNotFoundError:
        raise PackageNotFoundLocallyError(changed_package.name, local.address())
    install_package_products(descendant_package, channel, env)

    # export env - not possible with the api
    # - run as subprocess in the test environment
    export = run_command(Commands.RUN, "-n", env,
                         "conda", "env", "export")
    print(export[0])
    print("CHECKSUM = " + hashlib.md5(export[0]).hexdigest())

    test_scripts = []
    if descendant_package.sub_packages():
        for sub in descendant_package.sub_packages():
            test_scripts.extend(glob.glob(os.environ['CONDA_DIR'] + 'pkgs/' +
                                          sub + '-' +
                                          str(descendant_package.version()) +
                                          "*/info/test/run_test.*"))
    else:
        test_scripts.extend(glob.glob(os.environ['CONDA_DIR'] + 'pkgs/' +
                                      descendant_package.name() + '-' +
                                      str(descendant_package.version()) +
                                      "*/info/test/run_test.*"))

    for test in test_scripts:
        if test.endswith('.sh'):
            error = run_command(Commands.RUN, '-n', env, 'bash', test)[1]
            if error:
                raise TestFailError(error)
        elif test.endswith('.py'):
            error = run_command(Commands.RUN, 'python', '-n', env, test)[1]
            if error:
                raise TestFailError(error)
        elif test.endswith('.pl'):
            error = run_command(Commands.RUN, 'perl', '-n', env, test)[1]
            if error:
                raise TestFailError(error)
        else:
            raise ValueError('Unsupported test extension')

    changed_package.check_ldd(os.environ['CONDA_DIR'] + 'envs/' + env + '/bin/*', env)
    changed_package.check_ldd(os.environ['CONDA_DIR'] + 'envs/' + env + '/lib/*', env)


def main():

    recipe_book = RecipeBook(find_recipe_files('.'))

    changed_recipes = find_changed_recipe_files(".", args.changes)
    changed_recipe_book = RecipeBook(changed_recipes)

    # TODO: parallelise?
    # No need to sort the graphs
    for changed in changed_recipe_book.dependency_graph():
        if changed is not (None, None):
            changed_package = Package(changed, recipe_book)
            for descendant in recipe_book.package_descendants(changed):
                descendant_package = Package(descendant[0], recipe_book)
                for channel in (prod, devel, local):
                    env = 'test_env'
                    try:
                        test_descendant(changed_package, descendant_package,
                                        channel, env)
                        break
                    except PackagesNotFoundError as e:
                        run_command(Commands.REMOVE, '-n', env)
                        if channel is local:
                            raise PackageNotFoundLocallyError(*e.args)
                        print(descendant_package.name, 'not in', channel.address)
                    except ValueError or TestFailError or LibError:
                        if channel is local:
                            raise


class PackageNotFoundLocallyError(PackagesNotFoundError):
    """
    Raise when a package is not found in the local conda channel during installation
    """


class TestFailError(Exception):
    """
    Raise when a test script fails
    """


if __name__ == "__main__":
    main()
