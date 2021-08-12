import subprocess
from os.path import join, dirname, exists
import pytest

path = join(dirname(__file__))

if not exists(join(path, 'data', 'channel')):
    subprocess.run([join(path, 'data', 'make_channel.sh'), join(path, 'data')])

try:
    from package import Package
    from channel import Channel
except ModuleNotFoundError:
    pytest.fail("Please run the tests as `python -m pytest` from "
                "the `gitlab_test` directory to ensure that the "
                "modules are on the path", False)
