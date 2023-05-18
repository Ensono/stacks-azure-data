import logging

from collections import Counter

def config_uniqueness_check(config_list: list[dict], unique_key: str):
    key_counter = Counter(i[unique_key] for i in config_list)
    for config in config_list:
        if key_counter[config[unique_key]] == 1:
            continue
        else:
            logging.error(f"{unique_key} value is not unique: {config[unique_key]}")
            return False
    return True
