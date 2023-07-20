
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

# environment = Environment(undefined=SilentUndefined)


INGEST_DIR = "ingest/Ingest_SourceType_SourceName"
DQ_INGEST_DIR = "component_generation"


class Template(Enum):
    ADO = f"{INGEST_DIR}/de-ingest-ado-pipeline.yml.jinja"
    CONFIG = (
        f"{INGEST_DIR}/config/ingest_sources/Ingest_SourceType_SourceName.json.jinja"
    )
    ARM = f"{INGEST_DIR}/data_factory/pipelines/ARM_IngestTemplate.json.jinja"
    TF_DATASET = f"{INGEST_DIR}/data_factory/adf_datasets.tf.jinja"
    TF_LINKED_SERVICE = f"{INGEST_DIR}/data_factory/adf_linked_services.tf.jinja"
    TF_ADF_PIPELINE = f"{INGEST_DIR}/data_factory/adf_pipelines.tf.jinja"
    TF_VARS = f"{INGEST_DIR}/data_factory/vars.tf.jinja"
    TEST_E2E_FT = (
        f"{INGEST_DIR}/tests/end_to_end/features/azure_data_ingest.feature.jinja"
    )
    TEST_E2E_ENV = f"{INGEST_DIR}/tests/end_to_end/features/environment.py.jinja"
    TEST_UNIT = f"{INGEST_DIR}/tests/unit/test_azuresql_source_name.py.jinja"
    DQ_ARM = f"{DQ_INGEST_DIR}/data_factory/pipelines/ARM_IngestTemplate.json.jinja"
    DQ_SPARK = f"{DQ_INGEST_DIR}/spark_jobs/ingest_dq.py.jinja"
    DQ_ADO = f"{DQ_INGEST_DIR}/test_path/de-ingest-ado-pipeline.yml.jinja"


base_directory_path = f"./ingest/jobs/{config['pipeline']}"
Path(base_directory_path).mkdir(parents=True, exist_ok=True)
template_source_folder = "component_generation/templates/Ingest_SourceType_SourceName_DQ/" 
templateLoader = FileSystemLoader(searchpath=str(Path(template_source_folder).absolute()))
templateEnv = Environment(loader=templateLoader, undefined=SilentUndefined)

template_list = templateEnv.list_templates(extensions='.jinja')
print(template_list)
for temp in template_list:
    template = templateEnv.get_or_select_template(temp)
    template_filepath = Path(template.filename.split(template_source_folder,1)[1])
    template_path = template_filepath.parent
    template_filename = template_filepath.stem
    print(template_path)
    print(template_filename)
    Path(base_directory_path/template_path).mkdir(parents=True, exist_ok=True)
    template.stream(config).dump(f'{base_directory_path}/{template_path}/{template_filename}')
# print(template.render(config))
# template = templateEnv.get_template(TEMPLATE_FILE)
# outputText = template.render()  # this is where to put args to the template renderer


# template = environment.from_string(content)
# print(template)
# # environment.compile_templates(f"{DQ_INGEST_DIR}/templates/", zip=None)
# # template_list = environment.list_templates()
# # for temp in template_list:
#     # template = environment.select_template(temp)
# template.stream(config).dump(f'{config["pipeline"]}.yml')

# print(template.render(config))