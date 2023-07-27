from datetime import date
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class data_source_types(Enum):
    AZURE_SQL = "azure_sql"


class IngestConfig(BaseModel):
    dataset_name: str = Field(
        description="Dataset name, used to derive pipeline and linked service names."
    )
    pipeline_description: str = Field(
        description="Description of the pipeline to be created."
    )
    data_source_type: data_source_types = Field(description="Datasource type, at present this must be azure_sql.")

    key_vault_linked_service_name: str = Field(
        description="Name of the keyvault service to connect to."
    )
    data_source_password_key_vault_secret_name: str = Field(
        description="Secret name of the data source password."
    )
    data_source_connection_string_variable_name: str = Field(
        description="Variable name for the connection string."
    )

    ado_variable_groups_nonprod: list[str] = Field(
        description="List of required variable groups in non production environment."
    )
    ado_variable_groups_prod: list[str] = Field(
        description="List of required variable groups in production environment."
    )

    default_arm_deployment_mode: Optional[str] = Field(
        description="Deployment mode for terraform; if not set, the default is Incremental"
    )

    window_start_default: Optional[date] = Field(
        description="Date to set as start of default time window. Defaults to 2020-01-01"
    )
    window_end_default: Optional[date] = Field(
        description="Date to set as end of default time window. Defaults to 2020-01-31"
    )

    bronze_container: str = Field(description="Name of container for Bronze data")
    silver_container: Optional[str] = Field(
        description="Name of container for Silver data"
    )
    gold_container: Optional[str] = Field(description="Name of container for Gold data")
