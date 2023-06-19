from pydantic import BaseModel


class Expectation(BaseModel):
    expectation_type: str
    expectation_kwargs: dict


class ValidationConfig(BaseModel):
    column_name: str
    expectations: list[Expectation]


class DatasourceConfig(BaseModel):
    datasource_name: str
    datasource_type: str
    data_location: str
    expectation_suite_name: str
    validation_config: list[ValidationConfig]


class Config(BaseModel):
    container_name: str
    gx_directory_path: str
    dataset_name: str
    datasource_config: list[DatasourceConfig]
