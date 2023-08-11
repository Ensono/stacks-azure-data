# Entrypoint for PySparkle application.
import logging

import click
from click_loglevel import LogLevel

from pysparkle.data_quality.main import data_quality_main
from pysparkle.etl.gold import gold_main
from pysparkle.etl.silver import silver_main
from pysparkle.logger import setup_logger


@click.group()
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    """Pysparkle CLI."""
    setup_logger("pysparkle", log_level)


@click.command()
@click.option("--dataset-name", "-d", type=str, help="Name of a dataset to process.")
def silver(dataset_name):
    """Bronze to Silver processing.

    Requires the following environment variables to be set:
    - AZURE_TENANT_ID - Directory ID for Azure Active Directory application,
    - AZURE_CLIENT_ID - Application ID for Azure Active Directory application,
    - AZURE_CLIENT_SECRET - Service Principal Secret,
    - ADLS_ACCOUNT - ADLS account name,
    - BLOB_ACCOUNT - Blob Storage account name.
    """
    silver_main(dataset_name)


@click.command()
@click.option("--partitions", "-p", default=2)
def gold(partitions):
    """Silver to Gold processing."""
    gold_main(partitions)


@click.command()
@click.option("--config-path", help="Path to a JSON config inside an Azure Blob container.")
def data_quality(config_path):
    """Data Quality check."""
    data_quality_main(config_path)


cli.add_command(silver)
cli.add_command(gold)
cli.add_command(data_quality)


if __name__ == "__main__":
    cli(standalone_mode=False)
