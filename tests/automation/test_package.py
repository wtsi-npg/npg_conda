import re

import pytest
from pytest import mark as m

from automation.package import FailedTestError, LibError, Package, PackageError
from automation_fixtures import test_channel, test_recipebook

_ = test_channel
_ = test_recipebook


@m.describe("Package")
class TestPackage(object):
    @m.it("Can equate to an identical Package object")
    def test_equals(self):
        assert Package(("success", "1.0.0")) == Package(("success", "1.0.0"))
        assert Package(("success", "1.0.0")) != Package(("fail", "1.0.0"))

    @m.context("When constructed without a Recipebook")
    @m.it("Accessing sub-package names raises an error")
    def test_sub_packages_no_recipebook(self):
        with pytest.raises(PackageError,
                           match=r"^Cannot determine sub-packages"):
            Package(("sub", "1.0.0")).sub_packages()

    @m.context("When constructed with a Recipebook")
    @m.context("When a package has no sub-packages")
    @m.it("Finds an empty set of sub-package names")
    def test_sub_packages_empty(self, test_recipebook):
        assert Package(("success", "1.0.0"),
                       recipebook=test_recipebook).sub_packages() == set()

    @m.context("When constructed with a Recipebook")
    @m.context("When a package has sub-packages")
    @m.it("Finds a set of sub-package names")
    def test_sub_packages_recipebook(self, test_recipebook):
        assert Package(("sub", "1.0.0"),
                       recipebook=test_recipebook).\
                   sub_packages() == {"libsub", "libsub-dev"}

    @m.context("When package tests fail")
    @m.it("Raises an error")
    def test_run_test_scripts_fail(self, test_recipebook, mocker):
        test_env = "base"  # We need a valid environment for the mock
        mocker.patch("automation.package.Package.get_test_scripts",
                     return_value=["./tests/automation/fail"])

        with pytest.raises(FailedTestError):
            Package(("fail", "1.0.0"),
                    recipebook=test_recipebook).run_test_scripts(test_env)

    @m.context("When package tests pass")
    @m.it("Succeeds")
    def test_run_test_scripts_pass(self, test_recipebook, mocker):
        test_env = "base"  # We need a valid environment for the mock
        mocker.patch("automation.package.Package.get_test_scripts",
                     return_value=["./tests/automation/succeed"])

        Package(("success", "1.0.0"),
                recipebook=test_recipebook).run_test_scripts(test_env)

    @m.context("When we link against system libraries by mistake")
    @m.it("Raises an error")
    def test_ldd_fail(self, test_recipebook, mocker):
        test_env = "base"  # We need a valid environment for the mock
        test_path = "/home/ubuntu/miniconda3/envs/bin"
        ldd_result = "libsub.so.0 => /usr/lib/libsub.so.0" \
                     " (0x00007ffee9523000)"

        mocker.patch('automation.package.run_command',
                     return_value=(ldd_result, "", 0))

        with pytest.raises(LibError, match=re.escape(ldd_result)):
            Package(("sub", "1.0.0"),
                    recipebook=test_recipebook).check_ldd(test_path,
                                                          test_env)

    @m.context("When we link against Conda libraries")
    @m.it("Succeeds")
    def test_ldd_pass(self, test_recipebook, mocker):
        test_env = "base"  # We need a valid environment for the mock
        test_path = "/home/ubuntu/miniconda3/envs/bin"
        ldd_result = "libsub.so.0 => /home/ubuntu/miniconda3/lib/libsub.so.0" \
                     " (0x00007ffee9523000)"

        mocker.patch('automation.package.run_command',
                     return_value=(ldd_result, "", 0))

        Package(("sub", "1.0.0"),
                recipebook=test_recipebook).check_ldd(test_path,
                                                      test_env)
