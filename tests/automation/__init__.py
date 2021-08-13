import subprocess
from pathlib import Path
import pytest

test_path = Path(__file__).parent.parent
data_path = test_path / 'data' / 'automation'

if not Path.exists(data_path / 'channel'):
    subprocess.run([test_path.parent / 'scripts' / 'make_channel.sh',
                    data_path])

try:
    from automation.package import Package
    from automation.channel import Channel
except ModuleNotFoundError:
    pytest.fail("Please run the tests as `python -m pytest` from "
                "the `gitlab_test` directory to ensure that the "
                "modules are on the path", False)
