import logging
import shutil
import yaml

import click
from click_loglevel import LogLevel

from datastacks.logger import setup_logger
from datastacks.utils import render_template_components


@click.group()
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    setup_logger("datastacks", log_level)

@cli.group()
def generate():
    pass

@generate.command()
@click.option("--config-path", "-c", type=str, help="Absolute path to config file on local machine")
@click.option("--data-quality/--no-data-quality", "-dq/-ndq", default=False, help="Flag to determine whether to include data quality in template")
def ingest(config_path, data_quality):
    """Generate new ingest pipeline"""
    if data_quality:
        template_source_folder = "Ingest_SourceType_SourceName_DQ"
    else:
        template_source_folder = "Ingest_SourceType_SourceName"
    
    click.echo("Reading config from provided path...")
    with open(config_path, "r") as file:
        config = yaml.safe_load(file)
    click.echo("Successfully read config file.\n")

    template_source_path = f"de_templates/ingest/{template_source_folder}/"
    target_dir = f"de_workloads/ingest/{config['pipeline']}"

    click.echo("Rendering component templates with provided config...")
    render_template_components(config, template_source_path, target_dir)
    click.echo("Successfully rendered new component!")


if __name__ == "__main__":
    cli(standalone_mode=False)
