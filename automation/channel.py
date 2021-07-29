from typing import List, Tuple

from conda.cli.python_api import run_command, Commands

from .package import Package


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
    search = run_conda_command(Commands.SEARCH, channels, package_name,
                               override=override)
    if search[2] > 0:
        raise ChildProcessError(search[1])
    packages = []
    # remove title lines and final empty line
    for package in search[0].split("\n")[2:-1]:
        split = package.split()
        packages.append(Package((split[0], split[1])))
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
    install = run_conda_command(Commands.INSTALL, channels,
                                package, env, override)
    if install[2] > 0:
        raise ChildProcessError(install[1])
