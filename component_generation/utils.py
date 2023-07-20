from enum import Enum
from jinja2 import Environment, FileSystemLoader, Undefined
import yaml
import os
from pathlib import Path


class SilentUndefined(Undefined):
    def __str__(self):
        return (
            self._undefined_name
            if self._undefined_name is not None
            else super().__str__()
        )

    def __getattr__(self, name):
        return self.__class__(name=f"{self}.{name}")

    def __getitem__(self, name):
        return self.__class__(name=f"{self}[{name}]")


with open("component_generation/test_config_ingest.yaml", "r") as file:
    config = yaml.safe_load(file)

def render_template_component(config, template_source_path, target_dir):
    Path(target_dir).mkdir(parents=True, exist_ok=True)
    templateLoader = FileSystemLoader(searchpath=str(Path(template_source_path).absolute()))
    templateEnv = Environment(loader=templateLoader, undefined=SilentUndefined)

    template_list = templateEnv.list_templates(extensions='.jinja')
    for temp in template_list:
        template = templateEnv.get_template(temp)
        template_filepath = Path(template.filename.split(template_source_path,1)[1])
        template_path = template_filepath.parent
        template_filename = template_filepath.stem
        Path(target_dir/template_path).mkdir(parents=True, exist_ok=True)
        template.stream(config).dump(f'{target_dir}/{template_path}/{template_filename}')
