from enum import Enum
from jinja2 import Environment, FileSystemLoader, Undefined
import yaml
from pathlib import Path


def render_template_component(config, template_source_path, target_dir):
    Path(target_dir).mkdir(parents=True, exist_ok=True)
    templateLoader = FileSystemLoader(searchpath=str(Path(template_source_path).absolute()))
    templateEnv = Environment(loader=templateLoader, autoescape=True)

    template_list = templateEnv.list_templates(extensions='.jinja')
    for temp in template_list:
        template = templateEnv.get_template(temp)
        template_filepath = Path(template.filename.split(template_source_path,1)[1])
        template_path = template_filepath.parent
        template_filename = template_filepath.stem
        Path(target_dir/template_path).mkdir(parents=True, exist_ok=True)
        template.stream(config).dump(f'{target_dir}/{template_path}/{template_filename}')
