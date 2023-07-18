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


with open(
    "ingest/Ingest_SourceType_SourceName/de-ingest-ado-pipeline.yml.jinja", "r"
) as file:
    content = file.read()

template = environment.from_string(content)
print(template.render(config))


with open(
    "ingest/Ingest_SourceType_SourceName/config/ingest_sources/Ingest_SourceType_SourceName.json.jinja",
    "r",
) as file:
    content = file.read()

template = environment.from_string(content)
print(template.render(config))


with open(
    "ingest/Ingest_SourceType_SourceName_DQ/config/data_quality/ingest_dq.json", "r"
) as file:
    content = file.read()

template = environment.from_string(content)
print(template.render(config))


with open(
    "ingest/Ingest_SourceType_SourceName/tests/end_to_end/features/azure_data_ingest.feature.jinja",
    "r",
) as file:
    content = file.read()

template = environment.from_string(content)
print(template.render(config))
