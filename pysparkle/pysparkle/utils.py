# Helper functions for PySparkle
import os
import re


def find_placeholders(input_str: str) -> list[str]:
    """Finds all placeholders in the form {PLACEHOLDER} in the input string.

    Args:
        input_str: The input string possibly containing placeholders.

    Returns:
        A list of all found placeholders.
    """
    return re.findall(r"\{(.+?)\}", input_str)


def substitute_env_vars(input_str: str) -> str:
    """Replaces placeholders in the form {PLACEHOLDER} with corresponding environment variable values.

    Args:
        input_str: The input string possibly containing placeholders.

    Returns:
        The input string with placeholders replaced with environment variable values.
    """
    placeholders = find_placeholders(input_str)

    for placeholder in placeholders:
        env_var_value = os.getenv(placeholder)
        if env_var_value:
            input_str = input_str.replace("{" + placeholder + "}", env_var_value)

    return input_str


def filter_files_by_extension(paths: list[str], extension: str) -> list[str]:
    """Returns paths with the given extension.

    Args:
        paths: List of file paths.
        extension: File extension to filter by. Dot is not necessary, e.g. you can pass "csv".

    Returns:
        A list of file paths that end with the given extension.

    """
    if not extension.startswith("."):
        extension = f".{extension}"

    return [path for path in paths if path.endswith(extension)]
