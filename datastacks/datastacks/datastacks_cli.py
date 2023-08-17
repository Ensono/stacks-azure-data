"""Datastacks CLI Module.

This module provides command-line interfaces to generate and manage data workloads within the Stacks Data Platform.
"""
import logging

import click
from click_loglevel import LogLevel

from pysparkle.config import DEFAULT_CONFIG_CONTAINER
from pysparkle.data_quality.main import data_quality_main
from pysparkle.logger import setup_logger
from datastacks.utils import generate_pipeline
from datastacks.config import INGEST_TEMPLATE_FOLDER


@click.group()
@click.help_option("-h", "--help")
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    """Specify log level for Datastacks."""
    setup_logger("datastacks", log_level)


@cli.group()
@click.help_option("-h", "--help")
def generate():
    """Generate new data workload."""
    pass


@generate.command()
@click.help_option("-h", "--help")
@click.option("--config", "-c", type=str, help="Absolute path to config file on local machine")
@click.option(
    "--data-quality/--no-data-quality",
    "-dq/-ndq",
    default=False,
    help="Flag to determine whether to include data quality in template",
)
def ingest(config, data_quality):
    """Generate new data ingest workload."""
    generate_pipeline(config, data_quality, INGEST_TEMPLATE_FOLDER, "Ingest")


@cli.command()
@click.help_option("-h", "--help")
@click.option("--config-path", help="Path to a JSON config inside an Azure Blob container.")
@click.option(
    "--container",
    default=DEFAULT_CONFIG_CONTAINER,
    show_default=True,
    help="Name of the container for storing configurations.",
)
def run_dq(config_path, container):
    """Perform data quality check."""
    data_quality_main(config_path, container)


if __name__ == "__main__":
    cli()
