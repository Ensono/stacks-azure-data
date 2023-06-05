# Helper functions for interacting with Azure Data Lake Storage
import logging
import os

from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeServiceClient
from pyspark.sql import SparkSession

logger = logging.getLogger(__name__)

ENV_NAME_SERVICE_PRINCIPAL_SECRET = "AZURE_CLIENT_SECRET"
ENV_NAME_DIRECTORY_ID = "AZURE_TENANT_ID"
ENV_NAME_APPLICATION_ID = "AZURE_CLIENT_ID"
ENV_NAME_ADLS_ACCOUNT = "ADLS_ACCOUNT"


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


def check_env() -> None:
    """Checks if the environment variables for ADLS access are set.

    Raises:
        EnvironmentError: If any of the required environment variables are not set.
    """
    check_env_variable(ENV_NAME_SERVICE_PRINCIPAL_SECRET)
    check_env_variable(ENV_NAME_DIRECTORY_ID)
    check_env_variable(ENV_NAME_APPLICATION_ID)
    check_env_variable(ENV_NAME_ADLS_ACCOUNT)


def set_spark_properties(spark: SparkSession) -> None:
    """Sets Spark properties to configure Azure credentials to access Azure storage.

    Args:
        spark: Spark session.
    """
    adls_account = os.getenv(ENV_NAME_ADLS_ACCOUNT)
    spark.conf.set(f"fs.azure.account.auth.type.{adls_account}.dfs.core.windows.net", "OAuth")
    spark.conf.set(
        f"fs.azure.account.oauth.provider.type.{adls_account}.dfs.core.windows.net",
        "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    )
    spark.conf.set(
        f"fs.azure.account.oauth2.client.id.{adls_account}.dfs.core.windows.net",
        os.getenv(ENV_NAME_APPLICATION_ID),
    )
    spark.conf.set(
        f"fs.azure.account.oauth2.client.secret.{adls_account}.dfs.core.windows.net",
        os.getenv(ENV_NAME_SERVICE_PRINCIPAL_SECRET),
    )
    spark.conf.set(
        f"fs.azure.account.oauth2.client.endpoint.{adls_account}.dfs.core.windows.net",
        f"https://login.microsoftonline.com/{os.getenv(ENV_NAME_DIRECTORY_ID)}/oauth2/token",
    )


def get_directory_contents(container: str, path: str) -> list[str]:
    """Gets the contents of a specified directory in an Azure Data Lake Storage container.

    Args:
        container: The name of the container in the ADLS account.
        path: The directory path within the container for which to list contents.

    Returns:
        A list of paths for the files and subdirectories within the specified container.
    """
    adls_account = os.getenv(ENV_NAME_ADLS_ACCOUNT)
    adls_url = f"https://{adls_account}.dfs.core.windows.net"
    credential = DefaultAzureCredential()
    adls_client = DataLakeServiceClient(account_url=adls_url, credential=credential)
    file_system_client = adls_client.get_file_system_client(file_system=container)
    paths = file_system_client.get_paths(path=path)
    paths = [path.name for path in paths]
    logger.info(f"Directory contents: {paths}")
    return paths


def get_adls_file_url(container: str, file_name: str) -> str:
    """Constructs an Azure Data Lake Storage (ADLS) URL for a specific file.

    Args:
        container: The name of the ADLS container.
        file_name: The name of the file (including any subdirectories within the container).

    Returns:
        Full ADLS URL for the specified file.
    """
    adls_account = os.getenv(ENV_NAME_ADLS_ACCOUNT)
    return f"abfss://{container}@{adls_account}.dfs.core.windows.net/{file_name}"
