# -*- coding: utf-8 -*-
#
# Copyright © 2021 Genome Research Ltd. All rights reserved.
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
# @author Michael Kubiak <mk53@sanger.ac.uk>

import logging as log

from typing import List, Tuple

from conda.cli.python_api import run_command, Commands

from automation.package import Package


class Channel:
    """A Channel is a repository containing conda packages."""

    _address: str
    _content: List[Package]

    def __init__(self, address: str):
        self._address = address
        self._content = []

    def address(self) -> str:
        return self._address

    def content(self) -> List[Package]:
        if not self._content:
            self._content = search_channels([self], override=True)
        return self._content

    def has_package(self, nv: Tuple[str, str]) -> bool:
        """Returns true if a package is in this channel.

        Args:
            nv: the name, version tuple of a package

        Returns: bool

        """
        return nv in [package.nv() for package in self.content()]


def run_conda_command(command: str, channels: List[Channel], package: str = "",
                      env: str = "", override: bool = False) -> Tuple:
    """Runs a conda command and returns the output a list of the arguments
    to be passed to run_command

    Args:
        command: the conda command to run
        channels: List of channels to run the command in
        package: The affected package
        env: The conda environment on which to operate
        override: Add override-channels option if true

    Returns: Tuple
    """
    argument_list = [command]
    for channel in channels:
        argument_list.append("-c")
        argument_list.append(channel.address())
    if env:
        argument_list.append("-n")
        argument_list.append(env)
    if override:
        argument_list.append("--override-channels")
    argument_list.append(package)
    return run_command(*argument_list)


def search_channels(channels: List[Channel], package_name: str = "",
                    override: bool = False) -> List[Package]:
    """Runs conda search in the given channels

    Args:
        channels: List of channels to search
        package_name: Package name to search for, gets all packages if not set
        override: Add override-channels option if true

    Returns: List[Package]
    """
    stdout, stderr, code = run_conda_command(Commands.SEARCH, channels,
                                             package_name,
                                             override=override)
    if code > 0:
        raise ChildProcessError(stderr)
    packages = []
    # remove title lines and final empty line
    for package in stdout.split("\n")[2:-1]:
        name, version, _, _ = package.split()
        packages.append(Package((name, version)))
    return packages


def install_from_channels(channels: List[Channel], package: str,
                          env: str = "", override: bool = False):
    """Runs conda install to install a package from the given channels

    Args:
        channels: A list of channels from which to install the package
        package: A package string ('name', 'name==version', etc.) to install
        env: The name of the environment to install into
        override: Add override-channels option if true

    """
    _, stderr, code = run_conda_command(Commands.INSTALL, channels,
                                        package, env, override)
    if code > 0:
        raise ChildProcessError(stderr)
