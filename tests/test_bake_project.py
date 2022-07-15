import os
from contextlib import contextmanager

import pytest


@contextmanager
def cwd(path):
    oldpwd = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(oldpwd)


def test_bake_project(cookies):
    result = cookies.bake()
    assert result.exit_code == 0
    assert result.exception is None
    assert result.project_path.name == "godot-project"
    assert result.project_path.is_dir()

    addons_dir = result.project_path / "addons"
    autoload_dir = result.project_path / "autoload"
    resources_dir = result.project_path / "resources"
    scenes_dir = result.project_path / "scenes"
    src_dir = result.project_path / "src"
    tests_dir = result.project_path / "tests"

    project_entries = {f.name for f in result.project_path.iterdir()}
    assert project_entries == {
        ".bumpversion.cfg",
        ".editorconfig",
        ".gdlintrc",
        ".gitignore",
        ".gut_editor_config.json",
        ".gut_editor_shortcuts.cfg",
        ".gutconfig.json",
        "export_presets.cfg",
        "project.godot",
        "tox.ini",
        "README.md",
        ".github",
        "addons",
        "autoload",
        "resources",
        "scenes",
        "src",
        "tests",
    }

    addons_entries = {f.name for f in addons_dir.iterdir()}
    assert addons_entries == {"gut"}

    autoload_entries = {f.name for f in autoload_dir.iterdir()}
    assert autoload_entries == {"game.gd"}

    resources_entries = {f.name for f in resources_dir.iterdir()}
    assert resources_entries == {"icon.png", "default_env.tres", "theme_main.tres"}

    scenes_entries = {f.name for f in scenes_dir.iterdir()}
    assert scenes_entries == {
        "level_main.tscn",
        "menu_key_bindings.tscn",
        "menu_main.tscn",
        "menu_pause.tscn",
        "menu_settings.tscn",
        "ui_settings_edit.tscn",
    }

    src_entries = {f.name for f in src_dir.iterdir()}
    assert src_entries == {
        "console.gd",
        "logger.gd",
        "menu_pause.gd",
        "scenes.gd",
        "scn_map.gd",
        "settings.gd",
        "ui_input_edit.gd",
        "ui_key_bindings_edit.gd",
        "ui_quit_button.gd",
        "ui_settings_edit.gd",
        "ui_slider_label.gd",
        "ui_transition_button.gd",
        "ui_version_label.gd",
        "utils.gd",
    }

    tests_entries = {f.name for f in tests_dir.iterdir()}
    assert tests_entries == {
        "test_scenes",
        "test_game_manager.gd",
        "test_settings.gd",
        "config.ini",
    }

    workflow_dir = result.project_path / ".github" / "workflows"
    entries = {f.name for f in workflow_dir.iterdir()}
    assert entries == {"godot-tests.yml"}


def test_bake_with_web_export(cookies):
    result = cookies.bake(extra_context={"github_pages_export": "y"})
    assert result.exit_code == 0
    workflow_dir = result.project_path / ".github" / "workflows"
    entries = {f.name for f in workflow_dir.iterdir()}
    assert entries == {"godot-export.yml", "godot-tests.yml"}

    readme = result.project_path / "README.md"
    print(repr(readme.read_text("utf-8")))
    assert (
        readme.read_text("utf-8")
        == "# 🤖 Godot Project\n[![Made with Godot](https://img.shields.io/badge/Made%20with-Godot-478CBF?style=flat&logo=godot%20engine&logoColor=white)](https://godotengine.org)\n![Pulse](https://img.shields.io/github/commit-activity/m/verillious/godot-project)\n![Checks](https://github.com/verillious/godot-project/actions/workflows/godot-tests.yml/badge.svg)\n![Export](https://github.com/verillious/godot-project/actions/workflows/godot-export.yml/badge.svg)\n> A sample cookiecutter-godot project\n\n## 🙏 Credits\n\n🍪 This project was created with [cookiecutter](https://github.com/audreyr/cookiecutter) and the [verillious/cookiecutter-godot](https://github.com/verillious/cookiecutter-godot) project template.\n"
    )
