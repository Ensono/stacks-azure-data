from unittest.mock import patch

import pytest

from pysparkle.storage_utils import *
from tests.unit.conftest import TEST_DATA_DIR

TEST_ENV_VARS = {
    ENV_NAME_SERVICE_PRINCIPAL_SECRET: "secret",
    ENV_NAME_APPLICATION_ID: "app_id",
    ENV_NAME_DIRECTORY_ID: "dir_id",
    ENV_NAME_ADLS_ACCOUNT: "myadlsaccount",
    ENV_NAME_BLOB_ACCOUNT: "myblobaccount"
}


@patch.dict("os.environ", {"TEST_VAR": "value"}, clear=True)
def test_check_env_variable():
    check_env_variable("TEST_VAR")


def test_check_env_variable_raises():
    with pytest.raises(EnvironmentError):
        check_env_variable("TEST_VAR")


@patch.dict("os.environ", TEST_ENV_VARS, clear=True)
def test_check_env():
    check_env()


def test_check_env_raises():
    with pytest.raises(EnvironmentError):
        check_env()


@patch.dict("os.environ", TEST_ENV_VARS, clear=True)
def test_set_spark_properties(spark):
    set_spark_properties(spark)
    adls_account = os.getenv(ENV_NAME_ADLS_ACCOUNT)
    assert (
        spark.conf.get(f"fs.azure.account.auth.type.{adls_account}.dfs.core.windows.net") == "OAuth"
    )
    assert (
        spark.conf.get(f"fs.azure.account.oauth.provider.type.{adls_account}.dfs.core.windows.net")
        == "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider"
    )
    assert spark.conf.get(
        f"fs.azure.account.oauth2.client.id.{adls_account}.dfs.core.windows.net"
    ) == os.getenv(ENV_NAME_APPLICATION_ID)
    assert spark.conf.get(
        f"fs.azure.account.oauth2.client.secret.{adls_account}.dfs.core.windows.net"
    ) == os.getenv(ENV_NAME_SERVICE_PRINCIPAL_SECRET)
    assert (
        spark.conf.get(
            f"fs.azure.account.oauth2.client.endpoint.{adls_account}.dfs.core.windows.net"
        )
        == f"https://login.microsoftonline.com/{os.getenv(ENV_NAME_DIRECTORY_ID)}/oauth2/token"
    )


def test_get_directory_contents(mock_adls_client):
    paths = get_adls_directory_contents("test_container", "test_path")
    assert paths == [file for file in os.listdir(TEST_DATA_DIR)]


@patch.dict("os.environ", {ENV_NAME_ADLS_ACCOUNT: "myadlsaccount"}, clear=True)
def test_get_adls_file_url():
    container = "mycontainer"
    file_name = "myfolder/myfile.txt"

    expected_url = "abfss://mycontainer@myadlsaccount.dfs.core.windows.net/myfolder/myfile.txt"

    assert get_adls_file_url(container, file_name) == expected_url
