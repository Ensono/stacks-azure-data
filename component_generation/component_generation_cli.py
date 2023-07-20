import logging
import shutil

import click
from click_loglevel import LogLevel

from pysparkle.logger import setup_logger
from jinja2 import Environment, PackageLoader, select_autoescape

env = Environment(
    loader=PackageLoader("component_generation"),
    autoescape=select_autoescape()
)

@click.group()
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    setup_logger("component_generation", log_level)


@click.command()
@click.option("--config-path", "-c", type=str, help="Absolute path to config file on local machine")
@click.option("--data-quality/--no-data-quality", "-dq/", default=False, help="Flag to determine whether to include data quality in template")
def gen_ingest(config_path, data_quality):
    """Generate new ingest pipeline"""


    if data_quality:
        template_source_folder = "Ingest_SourceType_SourceName_DQ"
        template = env.get_template("ingest_dq_template.whatever") # Change to real file name
    else:
        template_source_folder = "Ingest_SourceType_SourceName"
        template = env.get_template("ingest_template.whatever") # Change to real file name

    template.stream(config).dumps(f'{config["pipeline_name"]}.')
