from __future__ import annotations

import glob
import os
import re
import sys
from typing import List, Tuple

from conda.cli.python_api import run_command, Commands
from packaging.version import Version

lib = os.path.realpath(os.path.join(os.path.dirname(__file__),
                                    "..", "..", "recipebook"))
if lib not in sys.path:
    sys.path.insert(0, lib)

from recipebook import RecipeBook


class Package:
    """A package is the output of a conda recipe, with a name, version number,
    and any number of sub-packages (including zero).
    """

    def __init__(self, nv: Tuple[str, Version], recipebook: RecipeBook = None) -> object:
        self._name = nv[0]
        self._version = nv[1]
        self._has_sub_packages = True
        self._sub_packages = None
        if recipebook:
            self.populate_sub_packages(recipebook)

    def name(self) -> str:
        return self._name

    def version(self) -> Version:
        return self._version

    def nv(self) -> Tuple[str, Version]:
        return self._name, self._version

    def equals(self, other: Package) -> bool:
        """Test equality with another Package object

        Args:
            other: The Package to compare with

        Returns: bool

        """
        return self.name() == other.name() and self.version() == other.version()

    def populate_sub_packages(self, recipe_book: RecipeBook):
        self._sub_packages = recipe_book.sub_packages((self._name, self._version))
        if not self._sub_packages:
            self._has_sub_packages = False

    def sub_packages(self, recipe_book: RecipeBook = None) -> List[str] or None:
        """Returns a list of subpackages of the package

        Args:
            recipe_book: The Recipebook in which to search for sub-packages

        Returns: List[str] or None if that package has no sub-packages

        """
        if self._has_sub_packages and not self._sub_packages:
            if recipe_book:
                self.populate_sub_packages(recipe_book)
            else:
                raise MissingRecipeBookError("No recipe book provided when sub_packages "
                                             "variable has not been populated")
        return self._sub_packages

    def get_test_scripts(self, recipe_book: RecipeBook = None) -> List[str]:
        test_scripts = []
        if recipe_book:
            self.populate_sub_packages(recipe_book)
        if self.sub_packages():
            for sub in self.sub_packages():
                test_scripts.extend(glob.glob(os.environ['CONDA_PREFIX'] + '/pkgs/' +
                                              sub + '-' +
                                              str(self.version()) +
                                              "*/info/test/run_test.*"))
        else:
            test_scripts.extend(glob.glob(os.environ['CONDA_PREFIX'] + '/pkgs/' +
                                          self.name() + '-' +
                                          str(self.version()) +
                                          "*/info/test/run_test.*"))
        return test_scripts

    def run_test_scripts(self, env: str, recipe_book: RecipeBook = None):
        test_scripts = self.get_test_scripts(recipe_book)
        for test in test_scripts:
            if test.endswith('.sh'):
                ret_val = run_command(Commands.RUN, '-n', env, 'bash', test)
                if ret_val[2] > 0:
                    raise TestFailError(ret_val[1])
            elif test.endswith('.py'):
                ret_val = run_command(Commands.RUN, 'python', '-n', env, test)
                if ret_val[2] > 0:
                    raise TestFailError(ret_val[1])
            elif test.endswith('.pl'):
                ret_val = run_command(Commands.RUN, 'perl', '-n', env, test)
                if ret_val[2] > 0:
                    raise TestFailError(ret_val[1])
            else:
                raise ValueError('Unsupported test extension: ' + test.split('.')[-1])

    # TODO: it may be possible to find library names in recipes,
    #  rather than assuming that they contain the package name
    def check_ldd(self, path: str, env: str):
        """Run ldd on executables and libraries in a path, and find uses of a
        system version of libraries containing the package name

        Args:
            path: The path to a directory of (or a single) executables or libraries
            env: The conda environment in which to run ldd
        """
        bin_ldd = run_command(Commands.RUN, '-n', env, 'ldd', path)
        for line in bin_ldd[0].split("\n"):
            if re.search(".*/usr/lib/.*", line):
                if self.sub_packages():
                    for sub in self.sub_packages():
                        if re.search(".*" + sub + ".*", line):
                            raise LibError(line)
                else:
                    if re.search(".*" + self.name() + ".*", line):
                        raise LibError(line)


class MissingRecipeBookError(Exception):
    """
    Raise when sub_packages is called without the variable set or a recipebook provided
    """


class TestFailError(Exception):
    """
    Raise when a test script fails
    """


class LibError(Exception):
    """
    Raise when a library or executable is pulling in the wrong version of a library
    """
