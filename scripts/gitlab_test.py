#! /usr/bin/env python3

from __future__ import annotations

from typing import List, Dict
import argparse
from conda.cli.python_api import run_command, Commands
import networkx as nx
import os
import sys
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


def search_channel(channels: List[str] = None, override: bool = False, package: str = "") -> List[str]:
    """Runs conda search in the given channels

    Args:
        channels: List of channels to search
        override: Add override-channels option if true
        package: Package to search for

    Returns: List[str]
    """
    argument_list = [Commands.SEARCH]
    for channel in channels:
        argument_list.append("-c")
        argument_list.append(channel)
    if override:
        argument_list.append("--override-channels")
    argument_list.append(package)
    search = run_command(*argument_list)
    if search[1]:
        raise ChildProcessError(search[1])
    return search[0].split("\n")


# TODO: Channel class, Package class to reduce number of arguments here
def test_descendant(sub_packages: List[str], version: str,
                    descendant_sub: List[str], descendant_version: str,
                    channel_contents: List[str], channel_address: str):
    """Run tests on the version of a dependant package that are in the provided
     channel when installed with the newly built (sub)packages

    Args:
        sub_packages: list of sub-packages of the newly built package
        version: the version number of the newly built package
        descendant_sub: a list of sub-packages of a package dependant on the
            newly built package
        descendant_version: the version number of the descendant package
        channel_contents: a list of the packages in a channel
        channel_address: the address to the channel from which to install
            the dependant package
    """
    # TODO: Create environment with newly built package/ sub-packages installed
    #   - Channel order: local, devel, defaults, forge?
    #       (for installing requirements of newly built package)
    # TODO: Install dependant package/sub-packages
    #   - Channel order: testing channel(prod/devel/local), defaults, forge?
    # TODO: export env - apparently not possible with the api, may just need to run as a subprocess
    # TODO: find and run test scripts (similarly to bash script)
    # TODO: Run ldd for all executables and search for system versions of the changed package's libraries


def main():
    channel_contents = {args.prod_channel: search_channel(channels=[args.prod_channel], override=True),
                        args.devel_channel: search_channel(channels=[args.devel_channel], override=True),
                        args.build_dir: search_channel(channels=[args.build_dir], override=True)}

    recipe_book = RecipeBook(find_recipe_files('.'))

    changed_recipes = find_changed_recipe_files(".", args.changes)
    changed_recipe_book = RecipeBook(changed_recipes)

    # TODO: parallelise?
    # No need to sort the graphs
    for root in changed_recipe_book.dependency_graph():
        if root is not (None, None):
            sub_packages = changed_recipe_book.sub_packages(root)
            for descendant in recipe_book.package_descendants(root):
                descendant_sub = recipe_book.sub_packages(descendant)
                descendant_version = descendant[1]
                if not descendant_sub:
                    descendant_sub = [descendant[0]]
                for address, content in channel_contents.values():
                    try:
                        test_descendant(sub_packages, root[1],
                                        descendant_sub, descendant_version,
                                        content, address)
                        break
                    except Exception: # TODO: specify exception(s)
                        pass


if __name__ == "__main__":
    main()
