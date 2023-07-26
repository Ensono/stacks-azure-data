import click
import yaml

from datastacks.config_class import IngestConfig
from jinja2 import Environment, FileSystemLoader
from pathlib import Path


def render_template_components(config: dict, template_source_path: str, target_dir: str) -> None:
    """Renders all templates within a given path with provided config, and saves results into a new target path,
    while maintaining folder structure and removing jinja file extensions.

    Args:
        config: Dict of config containing required templating params
        template_source_path: path containing templates to be rendered
        target_dir: Directory to render templates into
    """
    Path(target_dir).mkdir(parents=True, exist_ok=True)
    template_loader = FileSystemLoader(searchpath=str(Path(template_source_path).absolute()))
    template_env = Environment(loader=template_loader, autoescape=True)

    template_list = template_env.list_templates(extensions='.jinja')
    for temp in template_list:
        template = template_env.get_template(temp)
        template_filepath = Path(template.filename.split(template_source_path,1)[1])
        template_path = template_filepath.parent
        template_filename = template_filepath.stem
        Path(target_dir/template_path).mkdir(parents=True, exist_ok=True)
        template.stream(config).dump(f'{target_dir}/{template_path}/{template_filename}')


def generate_pipeline(config_path: str, dq_flag: bool, template_source_folder: str, stage_name: str) -> None:
    """Reads in config from given file, renders templates for new pipeline,
       and writes out to new path
    Args:
        config_path: Path to config file containing templating params
        dq_flag: Flag indicating whether to include data quality components or not
        template_source_folder: Name of the folder within the template directory which 
            contains the templates to be rendered
        stage_name: Name of the pipeline stage eg. Ingest
    """    
    click.echo("Reading config from provided path...")
    with open(config_path, "r") as file:
        config_dict = yaml.safe_load(file)
    config = IngestConfig.parse_obj(config_dict)

    click.echo("Successfully read config file.\n")

    template_source_path = f"de_templates/{stage_name}/{template_source_folder}/"
    target_dir = f"de_workloads/{stage_name}/{stage_name}_{config.dataset_name}"

    click.echo(f"Generating workload components for pipeline {stage_name}_{config.dataset_name}...")
    render_template_components(config, template_source_path, target_dir)
    if dq_flag:
        template_source_folder = f"{template_source_folder}_DQ"
        template_source_path = f"de_templates/{stage_name}/{template_source_folder}/"
        render_template_components(config, template_source_path, target_dir)
    click.echo(f"Successfully generated workload components: {target_dir}")