from pathlib import Path

import pytest
from conda_build.api import update_index

from automation.channel import Channel
from recipebook.recipebook import RecipeBook, find_recipe_files


def remove_index(path: Path):
    """Removes Conda channel index files and directories from path."""
    for pattern in [".cache/*", "*.json", "*.json.bz2", "index.html"]:
        for f in path.rglob(pattern):
            if f.is_file():
                f.unlink()
    for pattern in [".cache/*", ".cache", "noarch", "icons"]:
        for f in path.rglob(pattern):
            if f.is_dir():
                f.rmdir()


@pytest.fixture(scope="function")
def test_channel():
    path = Path("./tests/data/automation/channel").absolute()
    update_index(path)

    yield Channel(path.as_uri())
    remove_index(path)


@pytest.fixture(scope="function")
def test_recipebook():
    rb = RecipeBook()
    rb.add_recipes(find_recipe_files("./tests/data/automation/recipes"))
    return rb
