import logging

from collections import Counter

def config_uniqueness_check(config_list: list[dict], unique_key: str):
    key_counter = Counter(i[unique_key] for i in config_list)
    duplicates = [key for key, count in key_counter.items() if count > 1]
    if duplicates:
        logging.error(f"{unique_key} values are not unique: {', '.join(map(str, duplicates))}")
        return False
    return True
