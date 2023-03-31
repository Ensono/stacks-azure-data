"""
Utility module for interacting with JSON config files
"""
import json
from pathlib import Path


def get_config_folder() -> str:
    """
    Gets the path of the 'config' folder on the current filesystem
        :return: str path
    """
    project_root = Path(__file__).parent.parent
    return (project_root / "config").resolve()


def get_config_full_path(path: str) -> str:
    """
    Gets the full system path to the required resource
        :param path: Path of the required resource within the config folder
        :return: str path to the required resource
        :raise: KeyError if the resource is not found in the resources folder
    """
    resource = get_config_folder() / f"{path}"
    if Path(resource).exists() is False:
        raise KeyError(f"No resource at the path {resource} exists")
    return resource


def load_config_as_dict(path: str) -> dict:
    """
    Gets the contents of the required JSON resource and converts to a dictionary
        :param path: Path of the required resource within the config folder (e.g 'folder1/resource1.json')
        :return: dict
        :raise: KeyError if the resource is not found
    """
    with open(str(get_config_full_path(path))) as f:
        return json.load(f)


def load_configs_as_list(path: str) -> list[dict]:
    """
    Gets all JSON config files within the given path
        :param path: Path of the required resources folder within the config folder (e.g 'folder1')
        :return: list[dict]
        :raise: KeyError if the resources folder is not found
    """
    config_list = []
    files = Path(get_config_full_path(path)).glob("*.json")
    for file in list(files):
        with open(file) as f:
            config_list.append(json.load(f))

    return config_list
