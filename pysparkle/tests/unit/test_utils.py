from unittest.mock import patch

import pytest

from pysparkle.utils import *


TEST_ENV_VARS = {
    "TEST_VAR1": "value1",
    "TEST_VAR2": "value2",
    "ADLS_ACCOUNT": "value3"
}


@pytest.mark.parametrize(
    "input_str,expected",
    [
        (
            "abfss://raw@{ADLS_ACCOUNT}.dfs.core.windows.net/table_name",
            ["ADLS_ACCOUNT"],
        ),
        (
            "abcd{TEST_VAR1}{TEST_VAR2}",
            ["TEST_VAR1", "TEST_VAR2"],
        ),
        (
            "somestring{TEST_VAR3}{NONEXISTENT_VAR}123",
            ["TEST_VAR3", "NONEXISTENT_VAR"],
        ),
    ],
)
@patch.dict("os.environ", TEST_ENV_VARS, clear=True)
def test_find_placeholders(input_str, expected):
    assert find_placeholders(input_str) == expected


@patch.dict("os.environ", TEST_ENV_VARS, clear=True)
def test_substitute_env_vars():
    input_str = "{TEST_VAR1}_{TEST_VAR2}_{ADLS_ACCOUNT}_{NONEXISTENT_VAR}"

    assert substitute_env_vars(input_str) == "value1_value2_value3_{NONEXISTENT_VAR}"
