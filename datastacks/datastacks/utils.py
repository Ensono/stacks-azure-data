import click
import yaml

from pydantic import BaseModel
from datastacks.datastacks.config_class import IngestConfig
from jinja2 import Environment, FileSystemLoader
from pathlib import Path


def generate_target_dir(stage_name: str, dataset_name: str) -> str:
    """Uses stage name and name of the dataset to generate the target directory to write to.

    Args:
        stage_name: Name of the pipeline stage eg. Ingest
        dataset_name: Name of the dataset being processed

    Returns:
        Path to render template into
    """
    target_dir = f"de_workloads/{stage_name.lower()}/{stage_name.capitalize()}_{dataset_name}"
    return target_dir


def render_template_components(config: BaseModel, template_source_path: str, target_dir: str) -> None:
    """Renders all template components using the provided config.

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


def generate_pipeline(config_path: str, dq_flag: bool, template_source_folder: str, stage_name: str) -> str:
    """Generate a data pipeline workload into the project.

    Reads in config from given file, renders templates for new pipeline, writes out to new path, and returns the
    target directory it wrote out to. If directory already exists it asks for user input to confirm overwrite.

    Args:
        config_path: Path to config file containing templating params
        dq_flag: Flag indicating whether to include data quality components or not
        template_source_folder: Name of the folder within the template directory
            containing the templates to be rendered
        stage_name: Name of the pipeline stage eg. Ingest

    Returns:
        Path to rendered template
    """
    click.echo("Reading config from provided path...")
    with open(config_path, "r") as file:
        config_dict = yaml.safe_load(file)
    config = IngestConfig.parse_obj(config_dict)

    click.echo("Successfully read config file.\n")

    template_source_path = f"de_templates/{stage_name.lower()}/{template_source_folder}/"
    target_dir = generate_target_dir(stage_name, config.dataset_name)

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

    click.echo(f"Generating workload components for pipeline {stage_name}_{config.dataset_name}...")
    render_template_components(config, template_source_path, target_dir)
    if dq_flag:
        template_source_folder = f"{template_source_folder}_DQ"
        template_source_path = f"de_templates/{stage_name.lower()}/{template_source_folder}/"
        render_template_components(config, template_source_path, target_dir)
    click.echo(f"Successfully generated workload components: {target_dir}")

    return target_dir
