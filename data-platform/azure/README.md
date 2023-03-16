# Stacks - Azure Data Platform

## Pre-requisites

In order to work on the project, developers require:

* Python 3.10
* Poetry https://python-poetry.org/docs/
### Windows users
* A Linux distribution, e.g. WSL2 https://docs.microsoft.com/en-us/windows/wsl/install

### Setup Environment
Install the applications listed in the [Requirements](#requirements) section, and ensure Poetry is added to  your `$PATH`.

A Makefile has been created to assist with setting up the development environment. Run:
```bash
make setup_dev_environment
```

To install packages within Poetry, use (this will add the dependency to `pyproject.toml`):
```bash
poetry add packagename
```
to install a package for use only in the dev environment, use:
```bash
poetry add packagename --group dev
```
