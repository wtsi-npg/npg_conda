import os

import pytest
from conda.cli.python_api import Commands, run_command
from pathlib import Path
from . import test_path

from automation import package
from automation.channel import Channel

from recipebook.recipebook import RecipeBook, find_recipe_files

conda_path = Path(os.environ['CONDA_EXE']).parent.parent
data_path = test_path / 'data' / 'automation'

c = Channel(Path(data_path / 'channel').as_uri())
env = 'test_env'
run_command(Commands.CREATE, '-n', env)
success = package.Package(("success", "1.0.0"))
sub = package.Package(("sub", "1.0.0"))
fail = package.Package(("fail", "1.0.0"))
recipe_book = RecipeBook()
recipe_book.add_recipes(find_recipe_files(data_path / 'recipes'))


def test_equals():
    p1 = package.Package(("success", "1.0.0"))
    p2 = package.Package(("fail", "1.0.0"))
    assert success.equals(p1)
    assert not success.equals(p2)


def test_sub_packages():
    with pytest.raises(package.MissingRecipeBookError) as err:
        success.sub_packages()
    assert str(err.value) == 'No recipe book provided when sub_packages ' \
                             'variable has not been populated'
    assert success.sub_packages(recipe_book) == set()
    assert sub.sub_packages(recipe_book) == {"libsub", "libsub-dev"}


def test_get_test_scripts():
    test_scripts = success.get_test_scripts()
    assert str(conda_path) + \
           '/pkgs/success-1.0.0-0/info/test/run_test.sh' in test_scripts
    test_scripts = sub.get_test_scripts()
    assert str(conda_path) + \
           '/pkgs/libsub-dev-1.0.0-0/info/test/run_test.py' in test_scripts


def test_run_test_scripts(mocker):
    success.run_test_scripts(env)
    with pytest.raises(package.TestFailError) as err:
        fail.run_test_scripts(env, recipe_book)
    assert str(err.value) == ''
    mocker.patch('automation.package.Package.get_test_scripts',
                 return_value=[str(conda_path) +
                               '/pkgs/success-1.0.0-0/info/test/run_test.fake'])
    with pytest.raises(ValueError) as err:
        success.run_test_scripts(env)
    assert str(err.value) == 'Unsupported test extension: fake'


def test_ldd(mocker):
    mocker.patch('automation.package.run_command',
                 return_value=(
                     "libsub.so.0 => /usr/lib/libsub.so.0 (0x00007ffee9523000)",
                     "", 0))
    with pytest.raises(package.LibError) as err:
        sub.check_ldd("path", "env")
    assert str(
        err.value) == "libsub.so.0 => /usr/lib/libsub.so.0 (0x00007ffee9523000)"

    mocker.patch('automation.package.run_command',
                 return_value=(
                     "libsub.so.0 => /home/ubuntu/miniconda3/lib/libz.so.0 "
                     "(0x00007ffee9523000)",
                     "", 0))
    sub.check_ldd("path", "env")
