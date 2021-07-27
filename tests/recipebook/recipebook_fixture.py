import pytest

from recipebook.recipebook import RecipeBook, find_recipe_files


@pytest.fixture(scope="function")
def populated_recipebook():
    rb = RecipeBook()
    rb.add_recipes(find_recipe_files("./tests/data/recipebook/recipes"))
    return rb
