import logging

import click
from click_loglevel import LogLevel

from datastacks.datastacks.logger import setup_logger
from datastacks.datastacks.utils import generate_pipeline
from datastacks.datastacks.config import INGEST_TEMPLATE_FOLDER


@click.group()
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    """Specify log level for Datastacks."""
    setup_logger("datastacks", log_level)


@cli.group()
def generate():
    """Generate new data workload."""
    pass


@generate.command()
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


if __name__ == "__main__":
    cli(standalone_mode=False)
