from setuptools import setup, find_packages

setup(name="npg_conda",
      packages=find_packages('.', exclude=['tests']),
      url="https://github.com/wtsi-npg/npg_conda",
      license="GPL3",
      author="Keith James, Michael Kubiak",
      author_email="kdj@sanger.ac.uk",
      description="Tools used to generate and maintain the npg conda channel",
      use_scm_version=True,
      python_requires=">=3.8",
      setup_requires=[
              "setuptools_scm"
      ],
      install_requires=[
            "conda",
            "conda-build",
            "networkx",
      ],
      tests_require=[
              "pytest",
              "pytest-it"
      ],
      scripts=[
            "bin/build",
            "bin/gitlab_test",
            "bin/recipebook"
      ])
