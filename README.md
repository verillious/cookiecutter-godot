# 🍪🤖 cookiecutter-godot
[![Made for Godot](https://img.shields.io/badge/Made%20for-Godot-478CBF?style=flat&logo=godot%20engine&logoColor=white)](https://godotengine.org)
![Pulse](https://img.shields.io/github/commit-activity/m/verillious/cookiecutter-godot)
![Checks](https://github.com/verillious/cookiecutter-godot/actions/workflows/check.yml/badge.svg)
> A Cookiecutter template for [Godot](https://godotengine.org/) projects

## 🚩 Features

This tool will create a Godot project with the following features:

* Run formatting, linting, code-checking and other CI features with [tox](https://tox.readthedocs.io).
* [EditorConfig](https://editorconfig.org/): Maintain consistent coding styles for multiple developers working on the same project
* Testing with [GUT](https://github.com/bitwes/Gut)
* Linting and Formatting with [GDScript Toolkit](https://github.com/Scony/godot-gdscript-toolkit)
* [bump2version](https://github.com/c4urself/bump2version): Pre-configured version bumping and tagging with a single command
* Pre-configured to load mod `.pck` files from the user directory
* Optional export to github pages

## 🏃 Quickstart

### Generate a Godot project:

Cookiecutter works with python so [install it](https://www.python.org/downloads/) if you haven't already! (make sure you include pip and add it to your PATH)

Install the latest Cookiecutter if you haven't installed it yet (this requires Cookiecutter 1.4.0 or higher):

```shell
pip install -U cookiecutter
```

Create the project:

```shell
cookiecutter gh:verillious/cookiecutter-godot
```

### Run the tests:

Install [tox](https://tox.readthedocs.io) if you haven't installed it yet:

```shell
pip install -U tox
```

Run tox:

```shell
tox
```
