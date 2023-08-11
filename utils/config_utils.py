import json
import logging

from collections import Counter
from pathlib import Path


def config_uniqueness_check(config_list: list[dict], unique_key: str):
    """Checks dictionaries within the list and returns true if the unique_key provided is actually unique.

    Args:
        config_list: List of dictionaries containing config
        unique_key: Key to check for uniqueness
    """
    key_counter = Counter(i[unique_key] for i in config_list)
    duplicates = [key for key, count in key_counter.items() if count > 1]
    if duplicates:
        logging.error(f"{unique_key} values are not unique: {', '.join(map(str, duplicates))}")
        return False
    return True


def load_config_as_dict(path: str) -> dict:
    """Gets the contents of the required JSON resource and converts to a dictionary.

    Args:
        path: Path of the required resource (e.g 'folder1/resource1.json')

    Returns:
        Config as a dictionary
    """
    with open(path) as f:
        return json.load(f)


def load_configs_as_list(path: str) -> list[dict]:
    """Gets all JSON config files within the given path.

    Args:
        path: Path of the required resources folder within the config folder (e.g 'folder1')

    Returns:
        Configs as a list of dictionaries
    """
    config_list = []
    files = Path(path).glob("*.json")
    for file in list(files):
        with open(file) as f:
            config_list.append(json.load(f))
    return config_list
