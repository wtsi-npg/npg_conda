#!/usr/bin/env python
#
# Copyright © 2018, 2019 Genome Research Ltd. All rights reserved.
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

from packaging.version import Version, LegacyVersion, parse
from packaging.specifiers import SpecifierSet

import jinja2 as jj
import logging as log
import networkx as nx

import argparse
import functools
import os
import subprocess
import sys
import yaml


def parse_requirement(req_str):
    """
    Parse a software version requirement string conforming to the Conda
    match specification (Note: the OR operator '|' is not supported
    currently).

    e.g gcc >=4.6,<7.0

    The PEP440 package name and version specifier returned may be used
    to identify software that will fulfill the requirement described
    by the argument.

    :param req_str str: The requirement Conda match specification.

    :returns: The required package name, a combined required version
    specifier.

    :rtype: str, packaging.specifiers.SpecifierSet
    """
    parts = list(map(str.strip, req_str.split()))
    pkg_name = parts[0]
    spec_set = None

    if len(parts) > 1:
        spec_strs = parts[1].split(',')
        specs = [SpecifierSet(x) for x in spec_strs]
        spec_set = functools.reduce(lambda vx, vy: vx & vy, specs)

    return pkg_name, spec_set


def find_recipe_files(dir):
    """
    Return the absolute paths of Conda recipe meta.yaml files in a
    directory, recursively.

    :param dir str: The directory to search.

    :returns: Paths of recipe files.

    :rtype: list str
    """
    recipe_files = []
    for dir, _, files in os.walk(base):
        for file in files:
            if file == "meta.yaml":
                recipe_files.append(os.path.join(dir, file))
    return recipe_files


def find_changed_recipe_files(dir, branch="master"):
    """
    Return the paths of Conda recipe meta.yaml files where something in
    the recipe directory has changed relative to another git branch.

    :param dir str: The directory to search.

    :param branch str: The git branch to compare with.

    :returns: Paths of recipe files.

    :rtype: list str
    """
    try:
        out = subprocess.check_output(["git", "diff", "--name-only",
                                       "--diff-filter=d", branch, dir])
    except subprocess.CalledProcessError as e:
        log.error(e.output)
        raise e

    files = [line.rstrip() for line in out.decode("utf-8").split("\n")]
    dirs = list(set([os.path.dirname(f) for f in files]))
    dirs.sort()

    recipe_files = []
    for dir in dirs:
        recipe = os.path.join(dir, "meta.yaml")
        if (os.path.isfile(recipe)):
            recipe_files.append(recipe)

    log.info("Recipes changed relative to %s: %s", branch, recipe_files)
    return recipe_files


def make_template_env(recipe_files):
    """
    Make a new Jinjer2 template environment by loading Conda recipes
    as templates. Add some dummy template expansion functions so that
    we don't need the Conda itself to process the recipes.

    :param recipe_files list str: Paths of recipe files.

    :returns: A Jinja2 Environment

    :rtype: jinja2.Environment
    """
    templates = {}
    for f in recipe_files:
        with open(f) as t:
            templates[f] = t.read()

    # Hack to expand templates. The value of this may safely be incorrect;
    # we don't use the value, we simply need a dummy value to permit
    # template expansion.
    template_loader = jj.DictLoader(templates)
    template_env = jj.Environment(loader=template_loader)
    template_env.globals['PKG_BUILDNUM'] = 9999
    template_env.globals['compiler'] = lambda *args, **kwargs: None

    # Don't declare sub-package dependecies because they refer to
    # their own package and introduce a cycle in the graph.
    template_env.globals['pin_subpackage'] = lambda *args, **kwargs: None
    return template_env


def render_recipe(recipe_file, template_env):
    """
    Render a Conda recipe file (which contains Jinja2 templates) into
    a valid YAML document so that we can parse it. Return the YAML
    document.

    :param recipe_file str: The recipe file path.

    :param template_env jinja2.Environment: The Jinja2 template
    environment to use.

    :returns: YAML document.

    :rtype: str
    """
    log.info("Working on %s", recipe_file)
    template = template_env.get_template(recipe_file)
    return template.render()


def find_package_version(req_pkg, pkg_index, spec=None):
    """
    Return any available versions of a package within a range, or all
    versions if no range limit is supplied.

    :param req_pkg str: A package name.

    :param pkg_index dict: A mapping of package name to liost of
    availble versions.

    :param spec packaging.specifiers.Specifier: A specifier for
    acceptable versions.

    :returns: A list of matching versions.

    :rtype: list
    """
    candidates = pkg_index[req_pkg]
    return list(spec.filter(candidates)) if spec else candidates


def load_recipes(recipe_files):
    template_env = make_template_env(recipe_files)

    # Append to a dict list value
    def add_listval(dikt, key, value):
        if key in dikt:
            dikt[key].append(value)
        else:
            dikt[key] = [value]

    # This dict maps a (package name, version Specifier) to the recipe
    # file that defined it. It is used to determine which recipe to
    # use to build a package.
    pkg_recipes = {}

    # This dict contains lists of Versions of package.
    #
    # Key: package name
    #
    # Value: list of Versions of the package
    pkg_versions = {}

    # This dict describes the dependencies of a specific package
    # Version.  Dependencies may change from one version of a package
    # to another.
    #
    # Key: (package name, Version) tuple
    #
    # Value: list of (package name, version Specifier) tuples of dependencies
    pkg_requirements = {}

    # This dict describes the sub-packages produced by a package.
    #
    # Key: sub-package name
    #
    # Value: parent package name
    #
    pkg_outputs = {}

    for recipe_file in recipe_files:
        log.debug("recipe_file: %s", recipe_file)
        recipe = yaml.safe_load(render_recipe(recipe_file, template_env))

        pkg = recipe["package"]
        pkg_name = pkg["name"]

        pkg_version = parse(pkg["version"])
        add_listval(pkg_versions, pkg_name, pkg_version)
        log.debug("package name: %s %s", pkg_name, pkg_version)

        pkg_recipes[(pkg_name, pkg_version)] = recipe_file

        pkg_reqs = []
        base_reqs = recipe.get("requirements", {})
        pkg_reqs += base_reqs.get("host", [])
        pkg_reqs += base_reqs.get("run", [])

        # Also search outputs for requirements
        outputs = recipe.get("outputs", [])
        for output in outputs:
            output_name = output["name"]
            pkg_outputs[output_name] = pkg_name
            output_reqs = output.get("requirements", {})

            pkg_reqs += output_reqs.get("host", [])
            pkg_reqs += output_reqs.get("run", [])

        pkg_reqs = list(set(pkg_reqs))
        # Jinja2 macros appear as 'None' - filter any of these out
        pkg_reqs = [x for x in pkg_reqs if x != "None"]

        log.debug("Requirements for %s are: %s", pkg_name, pkg_reqs)

        for pkg_req in pkg_reqs:
            req, spec = parse_requirement(pkg_req)
            log.debug("%s version: %s requires %s version: %s",
                      pkg_name, pkg_version, req, spec)
            add_listval(pkg_requirements, (pkg_name, pkg_version),
                        (req, spec))

    return pkg_recipes, pkg_versions, pkg_requirements, pkg_outputs


def build_dependency_graph(graph, root_node,
                           pkg_versions, pkg_reqs, pkg_outputs):
    """
    Return a dependency DAG built from the data extracted from recipes
    by the load_recipes function.
    """
    graph.add_node(root_node)

    for pkg_name, versions in pkg_versions.items():
        for version in versions:
            ptup = (pkg_name, version)
            if ptup in pkg_reqs:
                reqs = pkg_reqs[ptup]
                log.debug("%s requires %s", ptup, reqs)

                num_reqs_located = 0
                for (req_pkg, spec) in reqs:
                    # Is the required package one of the packages we
                    # are building?
                    if req_pkg in pkg_versions:
                        v = max(find_package_version(req_pkg,
                                                     pkg_versions,
                                                     spec=spec))
                        graph.add_edge((req_pkg, v), ptup)
                        num_reqs_located += 1

                        log.debug("Need to build package "
                                  "%s %s of candidates %s",
                                  req_pkg, v, pkg_versions[req_pkg])
                    # Is the required package one of the sub-packages
                    # of the packages we are building?
                    else:
                        if req_pkg in pkg_outputs:
                            # Require the parent package rather than
                            # the sub-package
                            parent_pkg = pkg_outputs[req_pkg]
                            v = max(find_package_version(parent_pkg,
                                                         pkg_versions,
                                                         spec=spec))
                            graph.add_edge((parent_pkg, v), ptup)
                            num_reqs_located += 1

                            log.debug("Need to build (containing) package "
                                      "%s %s of candidates %s",
                                      parent_pkg, v, pkg_versions[parent_pkg])
                        else:
                            log.warning("Can't find required package %s",
                                        req_pkg)

                    if num_reqs_located == 0:
                        log.debug("%s has no locatable requirements", ptup)
                        graph.add_edge(ptup, root_node)
            else:
                log.debug("%s has no requirements", ptup)
                graph.add_edge(ptup, root_node)
    return graph


def is_root_node(node):
    return node == "root"


def print_node(node, pkg_recipes):
    if not is_root_node(node):
        recipe = pkg_recipes[node]
        print(node[0], node[1], os.path.dirname(recipe))


description = """
Reads Conda package recipe meta.yaml files under the specified
directory (recursively) and reports package dependency information.

If no package is specified (with --package <package name>), a
directed, acyclic graph of the inter-package dependencies is
calculated, and a topological sort of that graph is printed to
STDOUT. This information describes an order in which to build packages
whereby a later package will only depend on previously built packages,
never on package yet to be built. This feature is essential because
conda-build is no longer capable of recursive from-source builds [1].

If a package and version are specified (with --package <package name>
and --version <version>), a directed, acyclic graph of the
inter-package dependencies of its ancestors is calculated, and a
topological sort of that graph is printed to STDOUT. This describes
the sub-graph of packages that must be built prior to the specified
package version.

If the --changes <Git branch> option is used, only recipes that have
been changed and their ancestors will be reported, omitting
duplicates.

1. https://github.com/conda/conda-build/issues/2467

"""


parser = argparse.ArgumentParser(
    description=description,
    formatter_class=argparse.RawDescriptionHelpFormatter)

parser.add_argument("recipes",
                    help="Recipes directory, defaults to current directory",
                    type=str, nargs="?", default=".")

parser.add_argument("-p", "--package", type=str,
                    help="Report dependents (i.e. descendants) of the "
                    "specified package")
parser.add_argument("-v", "--version", type=str,
                    help="Report dependents (i.e. descendants) of the "
                    "specified package version")
parser.add_argument("-c", "--changes", type=str,
                    help="Report only on recipes that have changed "
                    "relative to another branch (defaults to 'master'")

parser.add_argument("--debug",
                    help="Enable DEBUG level logging to STDERR",
                    action="store_true")
parser.add_argument("--verbose",
                    help="Enable INFO level logging to STDERR",
                    action="store_true")

args = parser.parse_args()

level = log.ERROR
if args.debug:
    level = log.DEBUG
elif args.verbose:
    level = log.INFO
log.basicConfig(level=level)

base = args.recipes
recipe_files = find_recipe_files(base)

pkg_recipes, pkg_versions, pkg_requirements, pkg_outputs = \
    load_recipes(recipe_files)

root_node="root"
graph = nx.DiGraph(directed=True)
graph = build_dependency_graph(graph, root_node,
                               pkg_versions, pkg_requirements, pkg_outputs)

if args.package and args.version:
    # Print a subgraph for a specific package and version
    pv = (args.package, parse(args.version))
    if pv in graph:
        for node in nx.topological_sort(
                nx.subgraph(graph, nx.ancestors(graph, pv))):
            print_node(node, pkg_recipes)
    else:
        raise ValueError("Package {} version {} is not present "
                         "in the graph".format(pv[0], pv[1]))
elif (args.changes):
    # Print a unified list of all changed recipes
    changed_recipes = find_changed_recipe_files(base, args.changes)
    cpkg_recipes, cpkg_versions, cpkg_requirements, cpkg_outputs = \
        load_recipes(changed_recipes)
    for cpkg, cversions in cpkg_versions.items():
        for cversion in cversions:
            pv = (cpkg, cversion)
            if pv in graph:
                print_node(pv, pkg_recipes)
else:
    # Print everything
    for node in nx.topological_sort(graph):
        print_node(node, pkg_recipes)
