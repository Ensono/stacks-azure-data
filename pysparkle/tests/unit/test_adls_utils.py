from unittest.mock import patch

import pytest

from pysparkle.adls_utils import *
from pysparkle.const import *
from tests.unit.conftest import TEST_DATA_DIR


@patch.dict('os.environ', {'TEST_VAR': 'value'}, clear=True)
def test_check_env_variable():
    check_env_variable('TEST_VAR')


def test_check_env_variable_raises():
    with pytest.raises(EnvironmentError):
        check_env_variable('TEST_VAR')


@patch.dict('os.environ', {ENV_NAME_SERVICE_PRINCIPAL_SECRET: 'value'}, clear=True)
def test_set_env():
    set_env()
    assert os.environ[ENV_NAME_DIRECTORY_ID] == DIRECTORY_ID
    assert os.environ[ENV_NAME_APPLICATION_ID] == APPLICATION_ID


@patch.dict('os.environ', {ENV_NAME_SERVICE_PRINCIPAL_SECRET: 'value'}, clear=True)
def test_set_spark_properties(spark):
    set_spark_properties(spark)
    assert spark.conf.get(f'fs.azure.account.auth.type.{ADLS_ACCOUNT}.dfs.core.windows.net') == 'OAuth'
    assert (spark.conf.get(f'fs.azure.account.oauth.provider.type.{ADLS_ACCOUNT}.dfs.core.windows.net')
            == 'org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider')
    assert (spark.conf.get(f'fs.azure.account.oauth2.client.id.{ADLS_ACCOUNT}.dfs.core.windows.net')
            == APPLICATION_ID)
    assert (spark.conf.get(f'fs.azure.account.oauth2.client.secret.{ADLS_ACCOUNT}.dfs.core.windows.net')
            == os.getenv(ENV_NAME_SERVICE_PRINCIPAL_SECRET))
    assert (spark.conf.get(f'fs.azure.account.oauth2.client.endpoint.{ADLS_ACCOUNT}.dfs.core.windows.net')
            == f'https://login.microsoftonline.com/{DIRECTORY_ID}/oauth2/token')


def test_get_directory_contents(mock_adls_client):
    paths = get_directory_contents('test_container', 'test_path')
    assert paths == [file for file in os.listdir(TEST_DATA_DIR)]
