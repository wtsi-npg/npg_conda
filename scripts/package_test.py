import pytest
import package
from channel import Channel, install_from_channels
from packaging.version import Version
from conda.cli.python_api import Commands, run_command
import os
import sys
lib = os.path.realpath(os.path.join(os.path.dirname(__file__),
                                    "..", "tools", "recipebook"))
if lib not in sys.path:
    sys.path.insert(0, lib)
from recipebook import RecipeBook, find_recipe_files

c = Channel(os.path.join("file://", os.path.dirname(__file__), "data/channel"))
defaults = Channel('pkgs/main')
env = 'test_env'
run_command(Commands.CREATE, '-n', env)
success = package.Package(("success", Version("1.0.0")))
sub = package.Package(("sub", Version("1.0.0")))
fail = package.Package(("fail", Version("1.0.0")))
# libsub-dev requires libsub, so will add both of their directories to pkgs
for p in ['libsub-dev', success.name(), fail.name()]:
    install_from_channels([c, defaults], p, env, True)


def test_equals():
    p1 = package.Package(("success", Version("1.0.0")))
    p2 = package.Package(("fail", Version("1.0.0")))
    assert success.equals(p1)
    assert not success.equals(p2)


def test_sub_packages():
    with pytest.raises(package.MissingRecipeBookError) as err:
        success.sub_packages()
    assert str(err.value) == 'No recipe book provided when sub_packages ' \
                             'variable has not been populated'
    recipebook = RecipeBook(find_recipe_files(os.path.realpath(os.path.join(os.path.dirname(__file__),
                                                                            "data", "recipes"))))
    assert success.sub_packages(recipebook) is None
    assert sub.sub_packages(recipebook) == ["libsub", "libsub-dev"]


def test_get_test_scripts():
    test_scripts = success.get_test_scripts()
    assert os.environ['CONDA_PREFIX'] + '/pkgs/success-1.0.0-0/info/test/run_test.sh' in test_scripts
    test_scripts = sub.get_test_scripts()
    assert os.environ['CONDA_PREFIX'] + '/pkgs/libsub-dev-1.0.0-0/info/test/run_test.py' in test_scripts


def test_run_test_scripts(mocker):
    mocker.patch('package.Package.get_test_scripts', return_value=[os.environ['CONDA_PREFIX'] +
                                                                   '/pkgs/success-1.0.0-0/info/test/run_test.sh'])
    success.run_test_scripts(env)
    mocker.patch('package.Package.get_test_scripts', return_value=[os.environ['CONDA_PREFIX'] +
                                                                   '/pkgs/fail-1.0.0-0/info/test/run_test.sh'])
    with pytest.raises(package.TestFailError) as err:
        fail.run_test_scripts(env)
    assert str(err.value) == ''
    mocker.patch('package.Package.get_test_scripts', return_value=[os.environ['CONDA_PREFIX'] +
                                                                   '/pkgs/success-1.0.0-0/info/test/run_test.fake'])
    with pytest.raises(ValueError) as err:
        success.run_test_scripts(env)
    assert str(err.value) == 'Unsupported test extension: fake'


def test_ldd(mocker):
    mocker.patch('package.run_command',
                 return_value=("success.so.0 => /usr/lib/libz.so.0 (0x00007ffee9523000)", "", 0))
    with pytest.raises(package.LibError) as err:
        success.check_ldd("path", "env")
    assert str(err.value) == "success.so.0 => /usr/lib/libz.so.0 (0x00007ffee9523000)"

    mocker.patch('package.run_command',
                 return_value=("libsub.so.0 => /home/ubuntu/miniconda3/lib/libz.so.0 (0x00007ffee9523000)", "", 0))
    sub.check_ldd("path", "env")


run_command(Commands.REMOVE, '-n', env, '--all')
