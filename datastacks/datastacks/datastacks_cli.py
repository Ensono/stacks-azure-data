import logging

import click
from click_loglevel import LogLevel

from datastacks.logger import setup_logger
from datastacks.utils import generate_pipeline
from datastacks.config import INGEST_TEMPLATE_FOLDER


@click.group()
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    setup_logger("datastacks", log_level)


@cli.group()
def generate():
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
    """Generate new ingest pipeline"""
    generate_pipeline(config, data_quality, INGEST_TEMPLATE_FOLDER, "Ingest")


if __name__ == "__main__":
    cli(standalone_mode=False)
