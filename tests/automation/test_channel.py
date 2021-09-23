from pytest import mark as m

from automation.package import Package
from automation_fixtures import test_channel

_ = test_channel  # Prevent IDE optimising away the import


@m.describe("Channel")
class TestChannel(object):
    @m.it("Can list channel packages")
    def test_content(self, test_channel):
        expected = [Package(("fail", "1.0.0")),
                    Package(("libsub", "1.0.0")),
                    Package(("libsub-dev", "1.0.0")),
                    Package(("success", "1.0.0"))]
        packages = test_channel.content()
        packages.sort()
        assert packages == expected
