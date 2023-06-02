# Helper functions for interacting with Azure Data Lake Storage
import os

from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeServiceClient
from pyspark.sql import SparkSession
from pysparkle.const import ADLS_ACCOUNT, APPLICATION_ID, DIRECTORY_ID

ADLS_URL = f'https://{ADLS_ACCOUNT}.dfs.core.windows.net'
ENV_NAME_SERVICE_PRINCIPAL_SECRET = 'AZURE_CLIENT_SECRET'
ENV_NAME_DIRECTORY_ID = 'AZURE_TENANT_ID'
ENV_NAME_APPLICATION_ID = 'AZURE_CLIENT_ID'


def check_env_variable(var_name: str) -> None:
    """Checks if a given environment variable is set. If not, raises an EnvironmentError.

    Args:
        var_name: The name of the environment variable to check.

    Raises:
        EnvironmentError: If the environment variable is not set.
    """
    try:
        os.environ[var_name]
    except KeyError:
        raise EnvironmentError(f"Environment variable '{var_name}' not set.")


def set_env() -> None:
    """Sets environment variables to enable ADLS access."""
    check_env_variable(ENV_NAME_SERVICE_PRINCIPAL_SECRET)
    os.environ[ENV_NAME_DIRECTORY_ID] = DIRECTORY_ID
    os.environ[ENV_NAME_APPLICATION_ID] = APPLICATION_ID


def set_spark_properties(spark: SparkSession) -> None:
    """Sets Spark properties to configure Azure credentials to access Azure storage.

    Args:
        spark: Spark session.
    """
    spark.conf.set(f'fs.azure.account.auth.type.{ADLS_ACCOUNT}.dfs.core.windows.net', 'OAuth')
    spark.conf.set(f'fs.azure.account.oauth.provider.type.{ADLS_ACCOUNT}.dfs.core.windows.net',
                   'org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider')
    spark.conf.set(f'fs.azure.account.oauth2.client.id.{ADLS_ACCOUNT}.dfs.core.windows.net',
                   APPLICATION_ID)
    spark.conf.set(f'fs.azure.account.oauth2.client.secret.{ADLS_ACCOUNT}.dfs.core.windows.net',
                   os.getenv(ENV_NAME_SERVICE_PRINCIPAL_SECRET))
    spark.conf.set(
        f'fs.azure.account.oauth2.client.endpoint.{ADLS_ACCOUNT}.dfs.core.windows.net',
        f'https://login.microsoftonline.com/{DIRECTORY_ID}/oauth2/token')


def get_directory_contents(container: str, path: str) -> list[str]:
    """Gets the contents of a specified directory in an Azure Data Lake Storage container.

    Args:
        container: The name of the container in the ADLS account.
        path: The directory path within the container for which to list contents.

    Returns:
        A list of paths for the files and subdirectories within the specified container.
    """
    credential = DefaultAzureCredential()
    adls_client = DataLakeServiceClient(account_url=ADLS_URL, credential=credential)
    file_system_client = adls_client.get_file_system_client(file_system=container)
    paths = file_system_client.get_paths(path=path)
    paths = [path.name for path in paths]
    print(f'Directory contents: {paths}')
    return paths
