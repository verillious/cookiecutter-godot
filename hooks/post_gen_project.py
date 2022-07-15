from pathlib import Path
from os import remove

pkg_path = Path.cwd()

github_pages_export = "{{cookiecutter.github_pages_export}}" != "n"

if not github_pages_export:
    workflow_path = pkg_path / ".github" / "workflows" / "godot-export.yml"
    remove(workflow_path)
