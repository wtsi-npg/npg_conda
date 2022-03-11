import pytest
from conda.models.version import VersionSpec
from pytest import mark as m

from recipebook.recipebook import UnknownPackageError
from recipebook_fixtures import test_recipebook

_ = test_recipebook  # Prevent IDE optimising away the import


@m.describe("RecipeBook")
class TestRecipeBook(object):
    @m.context("Once populated")
    @m.it("Can list packages")
    def test_list_packages(self, test_recipebook):
        assert test_recipebook.packages() == ["baton-pkg",
                                              "htslib-pkg",
                                              "htslib-plugins",
                                              "irods",
                                              "libjansson-pkg"]

    @m.it("Can list package versions")
    def test_list_packages(self, test_recipebook):
        assert test_recipebook.package_versions("baton-pkg") == {"2.1.0",
                                                                 "3.0.0",
                                                                 "3.0.1"}

        with pytest.raises(UnknownPackageError):
            test_recipebook.package_versions("no-such-package")

    @m.it("Can list package requirements")
    def test_list_package_requirements(self, test_recipebook):
        pkg = ("baton-pkg", "3.0.1")
        assert test_recipebook.package_requirements(pkg) == \
            {("irods-dev", VersionSpec("4.2.7")),
             ("libjansson-dev", None),
             ("libssl-dev", None)}

    @m.it("Can list package descendants")
    def test_list_package_descendants(self, test_recipebook):
        pkg = ("irods", "4.2.7")

        g = test_recipebook.package_descendants(pkg)
        desc = [n for n in g.nodes()]
        desc.sort()
        assert desc == [("baton-pkg", "2.1.0"),
                        ("baton-pkg", "3.0.0"),
                        ("baton-pkg", "3.0.1"),
                        ("htslib-plugins", "201712")]

    @m.it("Can list package ancestors")
    def test_list_package_ancestors(self, test_recipebook):
        pkg = ("baton-pkg", "3.0.1")

        g = test_recipebook.package_ancestors(pkg)
        desc = [n for n in g.nodes()]
        desc.sort()
        assert desc == [("irods", "4.2.7"),
                        ("libjansson-pkg", "2.10"),
                        ("openssl-pkg", "1.0.2o")]

    @m.it("Can list package subpackages")
    def test_get_sub_packages(self, test_recipebook):
        assert test_recipebook.get_sub_packages(("baton-pkg", "3.0.1")) \
               == {"libbaton-dev", "libbaton", "baton"}
