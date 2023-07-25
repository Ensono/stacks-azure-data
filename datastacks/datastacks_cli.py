import logging
import shutil
import yaml

import click
from click_loglevel import LogLevel

from datastacks.logger import setup_logger
from datastacks.utils import render_template_components
from datastacks.config import IngestConfig

@click.group()
@click.option("--log-level", "-l", type=LogLevel(), default=logging.INFO)
def cli(log_level):
    setup_logger("datastacks", log_level)

@cli.group()
def generate():
    pass

@generate.command()
@click.option("--config", "-c", type=str, help="Absolute path to config file on local machine")
@click.option("--data-quality/--no-data-quality", "-dq/-ndq", default=False, help="Flag to determine whether to include data quality in template")
def ingest(config, data_quality):
    """Generate new ingest pipeline"""
    if data_quality:
        template_source_folder = "Ingest_SourceType_SourceName_DQ"
    else:
        template_source_folder = "Ingest_SourceType_SourceName"
    
    click.echo("Reading config from provided path...")
    with open(config, "r") as file:
        config_dict = yaml.safe_load(file)
    config = IngestConfig.parse_obj(config_dict)

    click.echo("Successfully read config file.\n")

    template_source_path = f"de_templates/ingest/{template_source_folder}/"
    target_dir = f"de_workloads/ingest/ingest_{config.common.dataset_name}"

    click.echo(f"Generating workload components for pipeline ingest_{config.common.dataset_name}...")
    render_template_components(config, template_source_path, target_dir)
    click.echo(f"Successfully generated workload components: {target_dir}")


if __name__ == "__main__":
    cli(standalone_mode=False)
