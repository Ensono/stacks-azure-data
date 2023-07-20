from enum import Enum
from jinja2 import Environment, Undefined
import yaml


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


with open("test_config_ingest.yaml", "r") as file:
    config = yaml.safe_load(file)

environment = Environment(undefined=SilentUndefined)


INGEST_DIR = "ingest/Ingest_SourceType_SourceName"
DQ_INGEST_DIR = "ingest/Ingest_SourceType_SourceName_DQ"


class Template(Enum):
    ADO = f"{INGEST_DIR}/de-ingest-ado-pipeline.yml.jinja"
    CONFIG = f"{INGEST_DIR}/config/ingest_sources/ingest_config.json.jinja"
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
    DQ_ADO = f"{DQ_INGEST_DIR}/de-ingest-ado-pipeline.yml.jinja"


with open(Template.ADO.value, "r") as file:
    content = file.read()

template = environment.from_string(content)
print(template.render(config))
