# Entrypoint for PySparkle application.
import logging

import click
from click_loglevel import LogLevel

from pysparkle.gold import gold_main
from pysparkle.logger import setup_logger
from pysparkle.silver import silver_main


@click.group()
@click.option('--log-level', '-l', type=LogLevel(), default=logging.INFO)
def cli(log_level):
    setup_logger('pysparkle', log_level)


@click.command()
@click.option('--dataset-name', '-d', type=str, help='Name of a dataset to process.')
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
@click.option('--partitions', '-p', default=2)
def gold(partitions):
    """Silver to Gold processing."""
    gold_main(partitions)


cli.add_command(silver)
cli.add_command(gold)


if __name__ == '__main__':
    cli(standalone_mode=False)
