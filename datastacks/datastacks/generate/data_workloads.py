"""Data Workload Generation Utilities.

This module provides utility functions to automate the generation of data pipelines and workloads. It facilitates
rendering templates based on the provided config, and writing out the rendered templates to the specified directories.
"""
import click

from datastacks.generate.template_config import WorkloadConfigBaseModel
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from typing import Type


def generate_target_dir(workload_type: str, name: str) -> str:
    """Generate the target directory name using workload_type and name of the dataset.

    Args:
        workload_type: Name of the pipeline type, e.g. Ingest or Processing
        name: Either the name of the dataset being processed or the pipeline.

    Returns:
        Path to render template into
    """
    target_dir = f"de_workloads/{workload_type}/{name}"
    return target_dir


def render_template_components(config: WorkloadConfigBaseModel, template_source_path: str, target_dir: str) -> None:
    """Render all template components using the provided config.

    Renders all templates within a given path with provided config, and saves results into a new target path,
    while maintaining folder structure and removing jinja file extensions, any existing files with the same name
    are overwritten.

    Args:
        config: Pydantic model of config containing required templating params
        template_source_path: Path containing templates to be rendered
        target_dir: Directory to render templates into
    """
    Path(target_dir).mkdir(parents=True, exist_ok=True)
    template_loader = FileSystemLoader(searchpath=str(Path(template_source_path).absolute()))
    template_env = Environment(loader=template_loader, autoescape=True, keep_trailing_newline=True)

    template_list = template_env.list_templates(extensions=".jinja")
    for template in template_list:
        template = template_env.get_template(template)
        template_filepath = Path(template.filename.split(template_source_path, 1)[1])
        template_path = template_filepath.parent
        template_filename = template_filepath.stem
        Path(target_dir / template_path).mkdir(parents=True, exist_ok=True)
        template.stream(config).dump(f"{target_dir}/{template_path}/{template_filename}")


def validate_yaml_config(path: str, WorkloadConfigModel: Type[WorkloadConfigBaseModel]) -> WorkloadConfigBaseModel:
    """Validates a YAML config with the WorkloadConfigModel provided.

    Reads in config from given file and returns the Pydantic model for the config, validated the structure.

    Args:
        path: Path to the YAML file containing config
        WorkloadConfigModel: Pydantic model used to validated config
    Returns:
        WorkloadConfigBaseModel of the validated config
    """
    click.echo("Reading config from provided path...")
    config = WorkloadConfigModel.from_yaml(path)
    click.echo("Successfully read config file.\n")
    return config


def generate_pipeline(validated_config: WorkloadConfigBaseModel, dq_flag: bool) -> str:
    """Generate a data pipeline workload into the project.

    Reads in config from given file, renders templates for new pipeline, writes out to new path, and returns the
    target directory it wrote out to. If directory already exists it asks for user input to confirm overwrite.

    Args:
        validated_config: Pydantic validated model of the config containing templating params
        dq_flag: Flag indicating whether to include data quality components or not
    Returns:
        Path to rendered template
    """
    workload_type = validated_config.workload_type.lower()
    templates_directory = "datastacks/datastacks/generate/templates"
    template_source_path = f"{templates_directory}/{workload_type}/{validated_config.template_source_folder}/"
    target_dir = generate_target_dir(workload_type, validated_config.name)

    if Path(f"{target_dir}").exists():
        click.echo(
            f"Target Directory {target_dir} already exists. "
            "Any files which are duplicated in the template will be overwritten."
        )
        if not click.confirm("Do you want to continue?"):
            click.echo("Terminating process.")
            return target_dir
        else:
            click.echo("Continuing with overwrite.")
    else:
        click.echo(f"Target Directory {target_dir} doesn't exist, creating directory.")

    click.echo(f"Generating workload components for pipeline {validated_config.name}...")
    render_template_components(validated_config, template_source_path, target_dir)
    if dq_flag:
        template_source_folder = f"{validated_config.template_source_folder}_DQ"
        template_source_path = f"{templates_directory}/{workload_type}/{template_source_folder}/"
        render_template_components(validated_config, template_source_path, target_dir)
    click.echo(f"Successfully generated workload components: {target_dir}")

    return target_dir
