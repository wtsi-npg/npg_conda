import pytest

from automation.channel import Channel
from automation.package import Package

from pathlib import Path
from . import test_path

c = Channel(Path(test_path / 'data' / 'automation' / 'channel').as_uri())


def test_content():
    expected = [Package(("fail", "1.0.0")),
                Package(("success", "1.0.0")),
                Package(("libsub", "1.0.0")),
                Package(("libsub-dev", "1.0.0"))]
    for package in c.content():
        if not any([package.equals(other) for other in expected]):
            pytest.fail(f'Wrong content:'
                        f'\ngot {str([p.nv() for p in c.content()])}'
                        f'\nexpected {str([p.nv() for p in expected])}')
