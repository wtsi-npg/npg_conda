# -*- coding: utf-8 -*-
#
# Copyright © 2019, 2020 Genome Research Ltd. All rights reserved.
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

import functools
import logging as log
import os
import subprocess
from typing import List, Dict, Tuple
from enum import Enum

import jinja2 as jj
import networkx as nx
import yaml
from packaging.specifiers import SpecifierSet, Specifier
from packaging.version import Version, parse

HOST = "host"
NAME = "name"
OUTPUTS = "outputs"
PACKAGE = "package"
REQUIREMENTS = "requirements"
RUN = "run"
VERSION = "version"


class PrintLevel(Enum):
    ROOT = 0
    SUB = 1
    GROUPED = 2


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
    pkg_versions: Dict[str, List[Version]]
    pkg_requirements: Dict[Tuple, List[Tuple]]
    pkg_parent: Dict[str, List]

    def __init__(self, recipe_files: List[str]):
        self.graph_root = (None, None)

        self.template_env = self.__make_template_env(recipe_files)

        # Maps a (package name, version Specifier) to the recipe file that
        # defined it. It is used to determine which recipe to use to build
        # a package.
        self.pkg_recipes = {}

        # Maps a package name to a list of Versions of the package.
        self.pkg_versions = {}

        # Maps a (package name, Version) to the dependencies of that version
        # of the package expressed as a list of (package name,
        # version Specifier) tuples.
        self.pkg_requirements = {}

        # Maps a sub-package name to the name its parent package.
        self.pkg_parent = {}

        self.log = log.getLogger(type(self).__name__)

        for f in recipe_files:
            self.add_recipe(f)

    def add_recipe(self, recipe_file: str) -> Dict:
        """Adds the packages defined in a recipe file.

        Args:
            recipe_file: A Conda metay.yaml recipe file.

        Returns: Dict

        """
        self.log.debug("Adding recipe_file: %s", recipe_file)
        recipe = yaml.safe_load(self.__render_recipe(recipe_file))

        def add_listval(dikt, key, value):
            if key in dikt:
                dikt[key].append(value)
            else:
                dikt[key] = [value]

        pkg = recipe[PACKAGE]
        pkg_name = pkg[NAME]
        pkg_version = parse(pkg[VERSION])

        add_listval(self.pkg_versions, pkg_name, pkg_version)
        self.log.debug("package name: %s %s", pkg_name, pkg_version)

        self.pkg_recipes[(pkg_name, pkg_version)] = recipe_file

        pkg_reqs = []
        base_reqs = recipe.get(REQUIREMENTS, {})
        pkg_reqs += base_reqs.get(HOST, [])
        pkg_reqs += base_reqs.get(RUN, [])

        # Also search outputs for requirements
        outputs = recipe.get(OUTPUTS, [])
        for output in outputs:
            output_name = output[NAME]
            try:
                self.pkg_parent[output_name].append(pkg_version)
            except KeyError:
                self.pkg_parent[output_name] = [pkg_name, pkg_version]
            output_reqs = output.get(REQUIREMENTS, {})

            pkg_reqs += output_reqs.get(HOST, [])
            pkg_reqs += output_reqs.get(RUN, [])

        pkg_reqs = list(set(pkg_reqs))
        # Jinja2 macros appear as 'None' - filter any of these out
        pkg_reqs = [x for x in pkg_reqs if x != "None"]

        self.log.debug("Requirements for %s are: %s", pkg_name, pkg_reqs)

        for pkg_req in pkg_reqs:
            req, spec = self.__parse_requirement(pkg_req)
            self.log.debug("%s version: %s requires %s version: %s",
                           pkg_name, pkg_version, req, spec)
            add_listval(self.pkg_requirements, (pkg_name, pkg_version),
                        (req, spec))

        return recipe

    def find_package_version(self, req_pkg: str,
                             spec=None) -> List[Version]:
        """Returns any available versions of a package within a range, or all
        versions if no range limit is supplied.

        Args:
            req_pkg: A package name.
            spec: A specifier for acceptable versions.

        Returns: List[Version]
        """
        candidates = self.package_versions(req_pkg)

        if spec:
            filtered = list(spec.filter(candidates))
            self.log.debug("Initial filter of %s with %s leaves: %s",
                           candidates, spec, filtered)

            def has_unmatched_local(f):
                """
                PEP440 states of its version specifiers:

                "If the specified version identifier is a public version
                 identifier (no local version label), then the local version
                 label of any candidate versions MUST be ignored when matching
                 versions."

                That means e.g. ==1.0.0 will match 1.0.0+2_abc123

                However, Conda version specifiers do require a match on the
                local version, so we need to filter out any candidates with
                a local version when looking for matches to a public version.

                Args:
                    f: PEP440 Version object

                Returns: Bool

                """

                for s in spec:
                    if s.operator == "==":
                        v = parse(s.version)
                        if f.local and not v.local:
                            self.log.debug("Filtering out %s because is has a "
                                           "local component not in spec %s",
                                           f, s)
                            return True
                return False

            filtered = [f for f in filtered if not has_unmatched_local(f)]
            self.log.debug("Final filter of %s with %s leaves: %s",
                           candidates, spec, filtered)
            candidates = filtered

        return candidates

    def packages(self) -> List[str]:
        """Returns the names of all packages.

        Returns: List[str]

        """
        return list(self.pkg_versions.keys())

    def package_recipe(self, nv: Tuple[str, Version]) -> str:
        """Returns the recipe for a package name and version.

        Args:
            nv: package name, version tuple

        Returns: Tuple[str, Version]

        """
        return self.pkg_recipes[nv]

    def package_requirements(self, nv: Tuple[str, Version]) -> \
            List[Tuple[str, Version]]:
        """Returns the requirements to build a package version as a list of
        package name, version tuples.

        Args:
            nv: package name, version tuple

        Returns: List[Tuple[str, Version]]

        """
        return self.pkg_requirements[nv]

    def package_versions(self, name: str) -> List[Version]:
        """Returns all versions of a named package as package name, version
         tuples.

        Args:
            name: package name

        Returns: List[Tuple[str, Version]]

        """
        return self.pkg_versions[name]

    def package_parent(self, name) -> str:
        """Returns the name of a package's parent or None.

        Args:
            name: package name

        Returns: str

        """
        return self.pkg_parent[name][0]

    def package_descendants(self, nv: Tuple[str, Version]) -> nx.DiGraph:
        """Returns a graph of all the packages that depend on the named
        package version.

        Args:
            nv: package name, version tuple

        Returns: nx.DiGraph

        """
        g = self.dependency_graph()
        return nx.subgraph(g, nx.descendants(g, nv))

    def package_ancestors(self, nv: Tuple[str, Version]) -> nx.DiGraph:
        """Returns a graph of all the packages on which the named package
         version depends.

        Args:
            nv: package name, version tuple

        Returns: nx.DiGraph

        """
        g = self.dependency_graph()
        return nx.subgraph(g, nx.ancestors(g, nv))

    def print_graph(self, level: PrintLevel):
        """Prints the entire package graph in topological sort order.

        Args:
            level: print level enum
        """
        self.__print_subgraph(self.dependency_graph(), level)

    def print_descendants(self, nv: Tuple[str, Version], level: PrintLevel):
        """Prints a sub-graph of packages and/or sub-packages that depend on
        the named package version.

        Args:
            nv: package name, version tuple
            level: print level Enum
        """
        self.__print_subgraph(self.package_descendants(nv), level)

    def print_ancestors(self, nv: Tuple[str, Version], level: PrintLevel):
        """Prints a sub-graph of packages and/or sub-packages on which the
        named package version depends.

        Args:
            nv: package name, version tuple
            level: print level enum
        """
        self.__print_subgraph(self.package_ancestors(nv), level)

    def print_root_package(self, nv: Tuple[str, Version]):
        """Prints only root package information.

        Args:
            nv: package name, version tuple
        """
        if nv in self.pkg_recipes:
            (name, version) = nv
            print(name, version, os.path.dirname(self.package_recipe(nv)))
        else:
            raise ValueError("RecipeBook does not contain {}".format(nv))

    def _has_sub_packages(self, name) -> bool:
        return name in [package[0] for package in self.pkg_parent.values()]

    def sub_packages(self, nv: Tuple[str, Version]) -> List[str] or None:
        """Returns a list of the subpackages of the provided root package

        Args:
            nv: package name, version tuple

        Returns: List[str] or None if that package has no subpackages
        """
        sub_packages = []
        if nv not in self.pkg_recipes:
            raise ValueError("RecipeBook does not contain {}".format(nv))
        elif not self._has_sub_packages(nv[0]):
            return None
        else:
            (name, version) = nv
            for sub, parent in self.pkg_parent.items():
                if parent[0] == name and version in parent:
                    sub_packages.append(sub)
        return sub_packages

    def print_sub_packages(self, nv: Tuple[str, Version]):
        """Prints only sub-package information.

        Args:
            nv: package name, version tuple
        """
        version = nv[1]
        try:
            for sub_package in self.sub_packages(nv):
                print(sub_package, version, os.path.dirname(self.package_recipe(nv)))
        except TypeError:
            # Print nothing if there are no subpackages
            pass

    def print_packages(self, nv: Tuple[str, Version]):
        """Prints root packages followed by their sub packages.

        Args:
            nv: package name, version tuple
        """

        print("root", end=" ")
        self.print_root_package(nv)
        if self._has_sub_packages(nv[0]):
            self.print_sub_packages(nv)

    def dependency_graph(self) -> nx.DiGraph:
        """
        Returns a dependency DAG built from the data extracted from recipes.
        """
        graph = nx.DiGraph(directed=True)
        graph.add_node(self.graph_root)

        def add_edge(pkg, spc):
            v = self.find_package_version(pkg, spec=spc)
            if v:
                m = max(v)
                graph.add_edge((pkg, m), nv)

                log.debug("To build %s %s we need %s from candidates %s",
                          pkg, spc, m, self.pkg_versions[pkg])
                return 1
            else:
                log.warning("Can't find version for %s required by %s",
                            pkg, nv)
                return 0

        for package_name, versions in self.pkg_versions.items():
            for version in versions:
                nv = (package_name, version)

                if nv in self.pkg_requirements:
                    reqs = self.pkg_requirements[nv]
                    log.debug("%s requires %s", nv, reqs)

                    num_reqs_located = 0
                    for (req_pkg, spec) in reqs:
                        # Is the required package one of the packages we
                        # are building?
                        if req_pkg in self.packages():
                            num_reqs_located += add_edge(req_pkg, spec)
                        # Is the required package one of the sub-packages
                        # of the packages we are building?
                        else:
                            if req_pkg in self.pkg_parent:
                                # Require the parent package rather than
                                # the sub-package
                                parent_pkg = self.package_parent(req_pkg)
                                num_reqs_located += add_edge(parent_pkg, spec)
                            else:
                                log.warning("Can't find required package %s",
                                            req_pkg)
                        if num_reqs_located == 0:
                            log.debug("%s has no locatable requirements", nv)
                            graph.add_edge(nv, self.graph_root)
                else:
                    log.debug("%s has no requirements", nv)
                    graph.add_edge(nv, self.graph_root)
        return graph

    def __print_subgraph(self, graph, level: PrintLevel):
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
    def __is_root_node(node: Tuple[str, Version]):
        return node[0] is None and node[1] is None

    @staticmethod
    def __make_template_env(recipe_files: List[str]) -> jj.Environment:
        """Makes a new Jinja2 template environment by loading Conda recipes as
        templates. Add some dummy template expansion functions so that we don't
        need the Conda itself to process the recipes.

        Args:
            recipe_files: Paths of recipe files.

        Returns: jinja2.Environment
        """
        templates = {}
        for f in recipe_files:
            with open(f) as t:
                templates[f] = t.read()

        # Hack to expand templates. The value of this may safely be incorrect;
        # we don't use the value, we simply need a dummy value to permit
        # template expansion.
        template_loader = jj.DictLoader(templates)
        env = jj.Environment(loader=template_loader)
        env.globals['PKG_BUILDNUM'] = 9999
        env.globals['compiler'] = lambda *args, **kwargs: None

        # Don't declare sub-package dependencies because they refer to
        # their own package and introduce a cycle in the graph.
        env.globals['pin_subpackage'] = lambda *args, **kwargs: None
        return env

    @staticmethod
    def __parse_requirement(req_str: str) -> Tuple[str, SpecifierSet]:
        """Parses a software version requirement string conforming to the Conda
        match specification.

        e.g gcc >=4.6,<7.0

        The tuple of PEP440 package name and version specifier returned may be
        used to identify software that will fulfill the requirement described
        by the argument.

        Args:
            req_str: The requirement Conda match specification.

        Returns: Tuple[str, SpecifierSet]
        """
        parts = list(map(str.strip, req_str.split()))
        pkg_name = parts[0]
        spec_set = None

        if len(parts) > 1:
            spec_set = SpecifierSet(parts[1])

        return pkg_name, spec_set

    def __render_recipe(self, recipe_file: str) -> str:
        """Renders a Conda recipe file (which contains Jinja2 templates) into
        a valid YAML document so that we can parse it. Return the YAML document.

        Args:
            recipe_file: The recipe file path.

        Returns: str
        """
        log.info("Working on %s", recipe_file)
        template = self.template_env.get_template(recipe_file)
        return template.render()


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
