# Entrypoint for PySparkle application.
import logging

import click
from click_loglevel import LogLevel

from pysparkle.gold import gold_main
from pysparkle.logger import setup_logger
from pysparkle.silver import silver_main
from pysparkle.data_quality.data_quality import data_quality_main


@click.group()
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    setup_logger("pysparkle", log_level)


@click.command()
@click.option("--dataset-name", "-d", type=str, help="Name of a dataset to process.")
def silver(dataset_name):
    """Bronze to Silver processing.

    \b
    Requires the following environment variables to be set:
    - AZURE_TENANT_ID - Directory ID for Azure Active Directory application,
    - AZURE_CLIENT_ID - Application ID for Azure Active Directory application,
    - AZURE_CLIENT_SECRET - Service Principal Secret,
    - ADLS_ACCOUNT - ADLS account name.
    """
    silver_main(dataset_name)


@click.command()
@click.option("--partitions", "-p", default=2)
def gold(partitions):
    """Silver to Gold processing."""
    gold_main(partitions)


dq_config = {
    "container_name": "staging",
    "dataset_name": "movies_metadata",
    "expectation_suite_name": "movies_metadata_suite",
    "validation_config": [
        {
            "column_name": "adult",
            "expectations": [
                {
                    "expectation_type": "expect_column_values_to_not_be_null",
                    "expectation_kwargs": {},
                }
            ],
        }
    ],
}


@click.command()
def data_quality():
    """Data Quality Checking."""
    data_quality_main(dq_config)


cli.add_command(silver)
cli.add_command(gold)
cli.add_command(data_quality)


if __name__ == "__main__":
    cli(standalone_mode=False)
