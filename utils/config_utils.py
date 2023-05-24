"""
Utility module for interacting with JSON config files
"""
import json
from pathlib import Path


def get_config_folder(stage: str = None, pipeline_name: str = None) -> str:
    """
    Gets the path of the 'config' folder on the current filesystem
        :param stage: Name of the stage we are looking to load config from eg. ingest
        :param pipeline_name: Name of the pipeline we are trying to retrieve config for
        :return: str path
    """
    project_root = Path(__file__).parent.parent
    if stage is not None:
        if pipeline_name is not None:
            return (project_root / stage / "jobs" / pipeline_name / "config").resolve()
        else:
            return (project_root / stage / "config").resolve()
    else:
        return (project_root / "config").resolve()


def get_config_full_path(path: str, stage: str = None, pipeline_name: str = None) -> str:
    """
    Gets the full system path to the required resource
        :param path: Path of the required resource within the config folder
        :param stage: Name of the stage we are looking to load config from eg. ingest
        :param pipeline_name: Name of the pipeline we are trying to retrieve config for
        :return: str path to the required resource
        :raise: KeyError if the resource is not found in the resources folder
    """
    resource = get_config_folder(stage, pipeline_name) / f"{path}"
    if Path(resource).exists() is False:
        raise KeyError(f"No resource at the path {resource} exists")
    return resource


def load_config_as_dict(path: str, stage: str = None, pipeline_name: str = None) -> dict:
    """
    Gets the contents of the required JSON resource and converts to a dictionary
        :param path: Path of the required resource within the config folder (e.g 'folder1/resource1.json')
        :param stage: Name of the stage we are looking to load config from eg. ingest
        :param pipeline_name: Name of the pipeline we are trying to retrieve config for
        :return: dict
        :raise: KeyError if the resource is not found
    """
    with open(str(get_config_full_path(path, stage, pipeline_name))) as f:
        return json.load(f)


def load_configs_as_list(path: str, stage: str = None, pipeline_name: str = None) -> list[dict]:
    """
    Gets all JSON config files within the given path
        :param path: Path of the required resources folder within the config folder (e.g 'folder1')
        :param stage: Name of the stage we are looking to load config from eg. ingest
        :param pipeline_name: Name of the pipeline we are trying to retrieve config for
        :return: list[dict]
        :raise: KeyError if the resources folder is not found
    """
    config_list = []
    files = Path(get_config_full_path(path, stage, pipeline_name)).glob("*.json")
    for file in list(files):
        with open(file) as f:
            config_list.append(json.load(f))

    return config_list
