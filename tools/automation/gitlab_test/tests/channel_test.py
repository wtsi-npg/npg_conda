import os

import pytest
from packaging.version import Version

from channel import Channel
from package import Package

c = Channel(os.path.join("file://", os.path.dirname(__file__), "data/channel"))


def test_content():
    expected = [Package(("fail", Version("1.0.0"))),
                Package(("success", Version("1.0.0"))),
                Package(("libsub", Version("1.0.0"))),
                Package(("libsub-dev", Version("1.0.0")))]
    for package in c.content():
        if not any([package.equals(other) for other in expected]):
            pytest.fail("Wrong content:\ngot " + str([p.nv() for p in c.content()]) +
                        "\nexpected " + str([p.nv() for p in expected]))
