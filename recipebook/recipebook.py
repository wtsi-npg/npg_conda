# -*- coding: utf-8 -*-
#
# Copyright © 2019, 2020, 2021 Genome Research Ltd. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# @author Keith James <kdj@sanger.ac.uk>

import logging as log
import os
import subprocess
from enum import Enum, unique
from typing import Dict, Final, List, Set, Tuple

import networkx as nx
from conda.exports import MatchSpec
from conda.models.version import VersionOrder, VersionSpec
from conda_build.api import render
from conda_build.metadata import MetaData

PACKAGE: Final = "package"
NAME: Final = "name"
VERSION: Final = "version"
REQUIREMENTS: Final = "requirements"
BUILD: Final = "build"
HOST: Final = "host"
RUN: Final = "run"


@unique
class PrintLevel(Enum):
    ROOT = 0
    SUB = 1
    GROUPED = 2


class UnknownPackageError(ValueError):
    pass


class RecipeBook(object):
    """A RecipeBook is a directed, acyclic graph (DAG) of Conda recipes. Each
    node is a package name, version tuple and each edge represents a dependency
    relationship. The graph is built by inspecting the meta.yaml files in a set
    of Conda recipes.

    As conda-build no longer supports from-source build dependency calculation,
    we use this method to sort our recipes when building them, ensuring a
    recipe has its dependencies built before it is itself built.
    """
    pkg_recipes: Dict[Tuple, str]
    pkg_versions: Dict[str, Set[str]]
    pkg_requirements: Dict[Tuple, Set[Tuple]]
    pkg_parent: Dict[str, str]
    pkg_subpackages: Dict[Tuple, Set[str]]

    def __init__(self):
        self.graph_root = (None, None)

        # Maps a (package name, version string) tuple to the recipe file that
        # defined it. It is used to determine which recipe to use to build
        # a package.
        self.pkg_recipes = {}

        # Maps a package name to a set of version strings that exist for that
        # package.
        self.pkg_versions = {}

        # Maps a (package name, version string) tuple to the dependencies of
        # that version of the package expressed as a list of
        # (package name, VersionSpec) tuples.
        self.pkg_requirements = {}

        # Maps a sub-package name to the name of its parent package.
        self.pkg_parent = {}

        # Maps a parent (package name, version string) tuple to a set of
        # sub-package names
        self.pkg_subpackages = {}

        self.log = log.getLogger(type(self).__name__)

        # WORKAROUND:
        #
        # Stop conda-build library loggers writing to STDOUT.
        #
        # conda-build loggers are apparently configurable by file, but how
        # isn't documented. They write to STDOUT, even when set to FATAL level
        # and pollute our output.
        #
        log.getLogger("conda_build.metadata").disabled = True
        log.getLogger("conda_build.variants").disabled = True

    def packages(self) -> List[str]:
        """Returns the names of all packages.

        Returns: List[str]

        """
        return list(self.pkg_versions.keys())

    def package_versions(self, pkg_name: str) -> Set[str]:
        """Returns all versions of a named package as package name, version
         tuples.

        Args:
            pkg_name: package name

        Returns: Set[str]

        """
        if pkg_name in self.pkg_versions:
            return self.pkg_versions[pkg_name]
        else:
            raise UnknownPackageError("Unknown package {}".format(pkg_name))

    def package_requirements(self, nv: Tuple[str, str]) -> \
            Set[Tuple[str, VersionSpec]]:
        """Returns the requirements of the names package version
        as a set of package name, VersionSpec tuples.

        Args:
            nv: package name, version tuple

        Returns: Set[Tuple[str, VersionSpec]]
        """
        if nv in self.pkg_requirements:
            return self.pkg_requirements[nv]
        else:
            raise UnknownPackageError("Unknown package {}".format(nv))

    def package_descendants(self, nv: Tuple[str, str]) -> nx.DiGraph:
        """Returns a graph of all the packages that depend on the named
        package version.

        Args:
            nv: package name, version tuple

        Returns: nx.DiGraph

        """
        g = self.dependency_graph()
        return nx.subgraph(g, nx.descendants(g, nv))

    def package_ancestors(self, nv: Tuple[str, str]) -> nx.DiGraph:
        """Returns a graph of all the packages on which the named package
         version depends.

        Args:
            nv: package name, version tuple

        Returns: nx.DiGraph

        """
        g = self.dependency_graph()
        return nx.subgraph(g, nx.ancestors(g, nv))

    def package_recipe(self, nv: Tuple[str, str]) -> str:
        """Returns the recipe for a package name and version.

        Args:
            nv: package name, version tuple

        Returns: str

        """
        if nv in self.pkg_recipes:
            return self.pkg_recipes[nv]
        else:
            raise UnknownPackageError("Unknown package {}".format(nv))

    def add_recipe(self, recipe_file: str):
        """Adds a single recipe."""
        self.log.debug("Processing recipe file {}".format(recipe_file))

        rendered = render(recipe_file, finalize=False)
        for i, r in enumerate(rendered):
            self.log.debug("Adding {} metadata [{}]".format(recipe_file, i))
            (metadata, _, _) = r
            self.__add_metadata(recipe_file, metadata)

    def add_recipes(self, recipe_files: List[str]):
        """Adds a list of recipes."""
        for f in recipe_files:
            self.add_recipe(f)

    def find_package_version(self, req_pkg: str,
                             spec=None) -> List[str]:
        """Returns any available versions of a package within a range, or all
        versions if no range limit is supplied.

        Args:
            req_pkg: A package name.
            spec: A specified for acceptable versions.

        Returns: List[str]
        """
        candidates = self.package_versions(req_pkg)

        if spec:
            filtered = []
            for version in candidates:
                if spec.match(version):
                    filtered.append(version)

            self.log.debug("Initial filter of {} with {} "
                           "leaves {}".format(candidates, spec, filtered))
            candidates = filtered

        return candidates

    def print_graph(self, level: PrintLevel):
        """Prints the entire package graph in topological sort order.

        Args:
            level: print level enum
        """
        self.__print_subgraph(self.dependency_graph(), level)

    def print_descendants(self, nv: Tuple[str, str], level: PrintLevel):
        """Prints a sub-graph of packages and/or sub-packages that depend on
        the named package version.

        Args:
            nv: package name, version tuple
            level: print level Enum
        """
        self.__print_subgraph(self.package_descendants(nv), level)

    def print_ancestors(self, nv: Tuple[str, str], level: PrintLevel):
        """Prints a sub-graph of packages and/or sub-packages on which the
        named package version depends.

        Args:
            nv: package name, version tuple
            level: print level enum
        """
        self.__print_subgraph(self.package_ancestors(nv), level)

    def print_root_package(self, nv: Tuple[str, str]):
        """Prints only root package information.

        Args:
            nv: package name, version tuple
        """
        if nv in self.pkg_recipes:
            (name, version) = nv
            print(name, version, os.path.dirname(self.package_recipe(nv)))
        else:
            raise UnknownPackageError("Unknown package {}".format(nv))

    def has_sub_packages(self, nv: Tuple[str, str]) -> bool:
        """Return true if the named package has sub-packages.

        Args:
            nv: package name, version tuple
        """
        return nv in self.pkg_subpackages

    def print_sub_packages(self, nv: Tuple[str, str]):
        """Prints only sub-package information, returns True if the package has
        no sub-packages.

        Args:
            nv: package name, version tuple
        """
        try:
            if nv in self.pkg_recipes:
                for sub in self.pkg_subpackages[nv]:
                    print(sub, nv[1], os.path.dirname(self.package_recipe(nv)))
            else:
                raise UnknownPackageError("Unknown package {}".format(nv))
        except KeyError:
            return True

    def print_packages(self, nv: Tuple[str, str]):
        """Prints root packages followed by their sub packages.

        Args:
            nv: package name, version tuple
        """

        print("root", end=" ")
        self.print_root_package(nv)
        if self.has_sub_packages(nv):
            self.print_sub_packages(nv)

    def dependency_graph(self) -> nx.DiGraph:
        """
        Returns a dependency DAG built from the data extracted from recipes.
        """
        graph = nx.DiGraph(directed=True)
        graph.add_node(self.graph_root)

        def add_edge(req_name: str, spc: VersionSpec):
            matching_versions = self.find_package_version(req_name, spec=spc)
            if matching_versions:
                # Conda version sorting is implemented by the VersionOrder
                # class
                vos = [VersionOrder(v) for v in matching_versions]
                max_version = str(max(vos))
                graph.add_edge((req_name, max_version), nv)

                self.log.debug("To build {} {} we are using {} "
                               "from candidates {}".format(req_name, spc,
                                                           max_version,
                                                           matching_versions))
                return 1
            else:
                self.log.warning("Can't find a suitable version for {} "
                                 "required by {}".format(req_name, nv))
                return 0

        for package_name, versions in self.pkg_versions.items():
            for version in versions:
                nv = (package_name, version)
                if nv in self.pkg_requirements:
                    reqs = self.package_requirements(nv)
                    self.log.debug("{} requires {}".format(nv, reqs))

                    num_reqs_located = 0
                    for (req_pkg, spec) in reqs:
                        # Is the required package one of the packages we
                        # are building?
                        if req_pkg in self.packages():
                            num_reqs_located += add_edge(req_pkg, spec)
                        # Is the required package one of the sub-packages
                        # of the packages we are building?
                        else:
                            # Require the parent package rather than the
                            # sub-package
                            if req_pkg in self.pkg_parent:
                                parent_pkg = self.pkg_parent[req_pkg]
                                num_reqs_located += add_edge(parent_pkg, spec)
                            else:
                                self.log.warning("Required package {} is not "
                                                 "included".format(req_pkg))

                    if num_reqs_located == 0:
                        self.log.debug("Package {} has no locatable "
                                       "requirements".format(nv))
                        graph.add_edge(nv, self.graph_root)
                else:
                    self.log.debug("Package {} has no requirements".format(nv))
                    graph.add_edge(nv, self.graph_root)
        return graph

    def __add_metadata(self, recipe_file: str, metadata: MetaData):
        pkg_name = metadata.name()
        pkg_version = metadata.version()
        effective_pkg_name = pkg_name

        if metadata.is_output:  # i.e. it's a sub-package
            toplevel = metadata.get_top_level_recipe_without_outputs()
            parent_pkg_name = toplevel[PACKAGE][NAME]

            # Map sub-package to parent
            self.__add_sub_package((parent_pkg_name, pkg_version), pkg_name)

            # We want to record subsequent details as if they apply to
            # the parent package because that's the package we'll actually
            # build. Sub-packages are built as a consequence of that. The
            # MetaData.ms_depends() method doesn't return a complete set of
            # requirements (that I can see).
            effective_pkg_name = parent_pkg_name

            # The MetaData objects for some recipes don't appear to include
            # toplevel requirements (needed to build the sub-package),
            # so we manually dig into the parsed Dict here.
            if REQUIREMENTS in toplevel:
                # We could also look at requirements["build"]
                if HOST in toplevel[REQUIREMENTS]:
                    nv = (effective_pkg_name, pkg_version)
                    for spec in toplevel[REQUIREMENTS][HOST]:
                        m = MatchSpec(spec)
                        self.__add_package_requirement(nv, (m.name, m.version))

        nv = (effective_pkg_name, pkg_version)
        self.__add_package_recipe(nv, recipe_file)
        self.__add_package_version(nv)

        for dep in metadata.ms_depends(HOST):
            self.__add_package_requirement(nv, (dep.name, dep.version))

        return

    def __add_package_recipe(self, nv: Tuple[str, str], recipe_file: str):
        self.pkg_recipes[nv] = recipe_file

    def __add_package_version(self, nv: Tuple[str, str]):
        pkg_name, pkg_version = nv
        if pkg_name in self.pkg_versions:
            self.pkg_versions[pkg_name].add(pkg_version)
        else:
            self.pkg_versions[pkg_name] = {pkg_version}

    def __add_sub_package(self, parent_nv: Tuple[str, str], sub_pkg_name: str):
        self.log.debug("Package {} has sub-package {}".format(parent_nv,
                                                              sub_pkg_name))
        parent_pkg_name, _ = parent_nv
        self.pkg_parent[sub_pkg_name] = parent_pkg_name
        if parent_nv in self.pkg_subpackages:
            self.pkg_subpackages[parent_nv].add(sub_pkg_name)
        else:
            self.pkg_subpackages[parent_nv] = {sub_pkg_name}

    def __add_package_requirement(self,
                                  pkg_nv: Tuple[str, str],
                                  dep_nv: Tuple[str, str]):
        self.log.debug("Package {} depends on {}".format(pkg_nv, dep_nv))
        if pkg_nv in self.pkg_requirements:
            self.pkg_requirements[pkg_nv].add(dep_nv)
        else:
            self.pkg_requirements[pkg_nv] = {dep_nv}

    def __print_subgraph(self, graph, level: PrintLevel):
        if level is None:
            level = PrintLevel.ROOT

        for node in nx.topological_sort(graph):
            if self.__is_root_node(node):
                continue
            elif level == PrintLevel.ROOT:
                self.print_root_package(node)
            elif level == PrintLevel.SUB:
                self.print_sub_packages(node)
            elif level == PrintLevel.GROUPED:
                self.print_packages(node)

    @staticmethod
    def __is_root_node(node: Tuple[str, str]):
        pkg_name, version = node
        return pkg_name is None and version is None


def find_recipe_files(root: str) -> List[str]:
    """Returns the absolute paths of Conda recipe meta.yaml files in a
     directory, recursively.

    Args:
        root: The directory to search.

    Returns: List[str]
    """
    recipe_files = []
    for d, _, files in os.walk(root):
        for file in files:
            if file == "meta.yaml":
                recipe_files.append(os.path.join(d, file))
    return recipe_files


def find_changed_recipe_files(root: str, branch="master") -> List[str]:
    """Returns the paths of Conda recipe meta.yaml files where something in the
    recipe directory has changed relative to another git branch.

    Args:
        root: The directory to search.
        branch: The git branch to compare with.

    Returns: List[str]
    """
    try:
        out = subprocess.check_output(["git", "diff", "--name-only",
                                       "--diff-filter=d", branch, root])
    except subprocess.CalledProcessError as e:
        log.error(e.output)
        raise e

    files = [line.rstrip() for line in out.decode("utf-8").split("\n")]
    dirs = list(set([os.path.dirname(f) for f in files]))
    dirs.sort()

    recipe_files = []
    for dir in dirs:
        recipe = os.path.join(dir, "meta.yaml")
        if os.path.isfile(recipe):
            recipe_files.append(recipe)

    log.info("Recipes changed relative to %s: %s", branch, recipe_files)
    return recipe_files
