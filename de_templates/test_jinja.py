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


with open("test_config_Ingest_AzureSql_SourceName.yaml", "r") as file:
    config = yaml.safe_load(file)

environment = Environment(undefined=SilentUndefined)
with open(
    "ingest/Ingest_AzureSql_SourceName/de-ingest-azuresql-source-name.yml.jinja", "r"
) as file:
    content = file.read()

template = environment.from_string(content)
print(template.render(config))
