from datetime import date
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class DataSourceType(Enum):
    """Enum containing supported data source types."""

    AZURE_SQL = "azure_sql"


class IngestConfig(BaseModel):
    """Pydantic definitions for data ingest workload generation config."""

    class Config:
        """Configuration for Pydantic model."""

        use_enum_values = True

    dataset_name: str = Field(description="Dataset name, used to derive pipeline and linked service names.")
    pipeline_description: str = Field(description="Description of the pipeline to be created.")
    data_source_type: DataSourceType = Field(description="Datasource type, at present this must be azure_sql.")

    key_vault_linked_service_name: str = Field(description="Name of the Key Vault linked service in Data Factory.")
    data_source_password_key_vault_secret_name: str = Field(
        description="Secret name of the data source password in Key Vault."
    )
    data_source_connection_string_variable_name: str = Field(description="Variable name for the connection string.")

    ado_variable_groups_nonprod: list[str] = Field(
        description="List of required variable groups in non-production environment."
    )
    ado_variable_groups_prod: list[str] = Field(
        description="List of required variable groups in production environment."
    )

    default_arm_deployment_mode: Optional[str] = Field(
        default="Incremental", description="Deployment mode for terraform."
    )

    window_start_default: Optional[date] = Field(
        default="2010-01-01", description="Date to set as start of default time window."
    )
    window_end_default: Optional[date] = Field(
        default="2010-01-31", description="Date to set as end of default time window."
    )

    bronze_container: str = Field(description="Name of container for Bronze data")
    silver_container: Optional[str] = Field(default=None, description="Name of container for Silver data")
    gold_container: Optional[str] = Field(default=None, description="Name of container for Gold data")
